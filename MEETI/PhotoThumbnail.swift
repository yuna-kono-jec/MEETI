import Foundation
import ImageIO
import CryptoKit

// 表示用だけ縮小する。保存している元写真は変更しない
@MainActor
final class PhotoThumbnail {
    static let shared = PhotoThumbnail()
    private let cache = NSCache<NSString, CGImage>()

    init() {
        // 縮小した写真を一時保管する。メモリ不足時は自動で減らせる
        cache.totalCostLimit = 32 * 1024 * 1024
        cache.countLimit = 24
    }

    func image(from data: Data, maxPixelSize: Int = 1024) async -> CGImage? {
        guard maxPixelSize > 0, !Task.isCancelled else { return nil }

        // 写真を見分ける計算も、画面操作を止めない場所で行う
        let digest = await Task.detached(priority: .userInitiated) {
            SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        }.value
        guard !Task.isCancelled else { return nil }

        let key = "\(maxPixelSize):\(digest)" as NSString
        if let image = cache.object(forKey: key) { return image }

        // 写真の展開と縮小をバックグラウンドで行う
        let decoding = Task.detached(priority: .userInitiated) {
            guard !Task.isCancelled else { return nil as CGImage? }
            return autoreleasepool {
                Self.decode(data, maxPixelSize: maxPixelSize)
            }
        }
        let decoded = await withTaskCancellationHandler {
            await decoding.value
        } onCancel: {
            decoding.cancel()
        }
        guard !Task.isCancelled, let image = decoded else { return nil }

        // 同じ写真の処理が先に終わっていたら、その画像を使う
        if let cached = cache.object(forKey: key) { return cached }
        cache.setObject(image, forKey: key, cost: image.bytesPerRow * image.height)
        return image
    }
    // 向きを直しながら、指定した画素数以内に縮小する
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
