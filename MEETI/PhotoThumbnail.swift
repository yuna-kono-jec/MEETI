import Foundation
import ImageIO
import CryptoKit

// 表示用にだけ写真を縮小します。SwiftDataの写真やアップロード元データは変更しません。
// メインアクターでキャッシュ操作を直列化し、重い元画像の再デコードを画面更新ごとに繰り返しません。
@MainActor
final class PhotoThumbnail {
    static let shared = PhotoThumbnail()
    private let cache = NSCache<NSString, CGImage>()

    init() {
        // キャッシュ（再利用用の一時保管）の上限。メモリ不足時はOSが画像を破棄できます。
        cache.totalCostLimit = 32 * 1024 * 1024
        cache.countLimit = 24
    }

    func image(from data: Data, maxPixelSize: Int = 1024) -> CGImage? {
        guard maxPixelSize > 0 else { return nil }
        // 個人情報を含むDataそのものをキーとして保持せず、写真の更新も区別します。
        let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        let key = "\(maxPixelSize):\(digest)" as NSString
        if let image = cache.object(forKey: key) { return image }
        guard let image = Self.decode(data, maxPixelSize: maxPixelSize) else { return nil }
        cache.setObject(image, forKey: key, cost: image.bytesPerRow * image.height)
        return image
    }
    // UIKitの画面状態に触れない縮小処理。プロフィールではバックグラウンドから呼び出します。
    nonisolated static func decode(_ data: Data, maxPixelSize: Int = 1024) -> CGImage? {
        guard maxPixelSize > 0 else { return nil }
        guard let source = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldCache: false] as CFDictionary),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
                kCGImageSourceShouldCacheImmediately: true
              ] as CFDictionary) else { return nil }
        return image
    }

}
