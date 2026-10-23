import Foundation
import ImageIO

// 実機速度の代用ではなく、同じMacで画像展開と縮小画像再利用の処理単体を比較する測定です。
// 実行：swiftc -parse-as-library MEETI/PhotoThumbnail.swift Tools/PhotoThumbnailBenchmark.swift -o /tmp/meeti-photo-bench
@main
struct PhotoThumbnailBenchmark {
    @MainActor
    static func main() async throws {
        let context = CGContext(data: nil, width: 4032, height: 3024, bitsPerComponent: 8,
                                bytesPerRow: 4032 * 4, space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
        context.setFillColor(CGColor(red: 0.4, green: 0.6, blue: 0.5, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: 4032, height: 3024))
        let bytes = NSMutableData()
        let destination = CGImageDestinationCreateWithData(bytes, "public.jpeg" as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, context.makeImage()!, nil)
        precondition(CGImageDestinationFinalize(destination))
        let data = bytes as Data
        func median(_ samples: [Double]) -> Double { samples.sorted()[samples.count / 2] }
        func measure(_ work: () -> Void) -> Double {
            let start = ProcessInfo.processInfo.systemUptime
            autoreleasepool(invoking: work)
            return (ProcessInfo.processInfo.systemUptime - start) * 1000
        }
        func measureAsync(_ work: () async -> Void) async -> Double {
            let start = ProcessInfo.processInfo.systemUptime
            await work()
            return (ProcessInfo.processInfo.systemUptime - start) * 1000
        }
        // 画像の全画素展開を伴う旧表示経路の比較用。UIKit描画全体を測っているわけではありません。
        func fullImage() -> CGImage {
            let source = CGImageSourceCreateWithData(data as CFData, nil)!
            return CGImageSourceCreateImageAtIndex(source, 0, [kCGImageSourceShouldCacheImmediately: true] as CFDictionary)!
        }
        let full = fullImage()
        let cache = PhotoThumbnail()
        let thumbnail = await cache.image(from: data)!
        var fullTimes: [Double] = [], coldTimes: [Double] = [], warmTimes: [Double] = []
        for _ in 0..<15 {
            fullTimes.append(measure { _ = fullImage() })
            coldTimes.append(await measureAsync { _ = await PhotoThumbnail().image(from: data) })
            warmTimes.append(await measureAsync { _ = await cache.image(from: data) })
        }
        let result: [String: Any] = [
            "environment": "Mac host, optimized Swift build, synthetic 4032x3024 JPEG; not iPhone app measurements",
            "samples": 15, "jpegBytes": data.count,
            "fullDecodeMedianMs": median(fullTimes), "thumbnailColdMedianMs": median(coldTimes),
            "thumbnailCachedMedianMs": median(warmTimes),
            "fullDecodedBufferBytes": full.bytesPerRow * full.height,
            "thumbnailDecodedBufferBytes": thumbnail.bytesPerRow * thumbnail.height
        ]
        let json = try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys])
        print(String(decoding: json, as: UTF8.self))
    }
}
