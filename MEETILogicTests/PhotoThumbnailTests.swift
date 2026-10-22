import XCTest
import ImageIO
@testable import MEETILogic

// 表示用縮小が元データを変更せず、向き・縦横比・写真の切り替えを保つことを検証します。
final class PhotoThumbnailTests: XCTestCase {
    @MainActor
    func testDownsamplesAndReusesDecodedImage() throws {
        let data = try jpeg(width: 2400, height: 1800)
        let cache = PhotoThumbnail()
        let first = try XCTUnwrap(cache.image(from: data))
        XCTAssertEqual(first.width, 1024)
        XCTAssertEqual(first.height, 768)
        XCTAssertTrue(first === cache.image(from: data))
        let smaller = try XCTUnwrap(cache.image(from: data, maxPixelSize: 512))
        XCTAssertEqual(smaller.width, 512)
        XCTAssertEqual(smaller.height, 384)
    }

    @MainActor
    func testAppliesCameraOrientation() throws {
        let data = try jpeg(width: 1200, height: 800, orientation: 6)
        let image = try XCTUnwrap(PhotoThumbnail().image(from: data, maxPixelSize: 600))
        XCTAssertEqual(image.width, 400)
        XCTAssertEqual(image.height, 600)
    }

    @MainActor
    func testDifferentPhotosDoNotShareCachedImage() throws {
        let cache = PhotoThumbnail()
        let first = try XCTUnwrap(cache.image(from: jpeg(width: 60, height: 40)))
        let second = try XCTUnwrap(cache.image(from: jpeg(width: 40, height: 60)))
        XCTAssertFalse(first === second)
        XCTAssertEqual(second.height, 60)
    }

    // プロフィール画面と同じバックグラウンド経路でも、縦写真の向きと比率が保たれます。
    func testBackgroundDecodePreservesOrientation() async throws {
        let data = try jpeg(width: 1200, height: 800, orientation: 6)
        let decoded = await Task.detached {
            PhotoThumbnail.decode(data, maxPixelSize: 600)
        }.value
        let image = try XCTUnwrap(decoded)
        XCTAssertEqual(image.width, 400)
        XCTAssertEqual(image.height, 600)
    }

    @MainActor
    func testInvalidInputFallsBackWithoutCrashing() {
        let cache = PhotoThumbnail()
        XCTAssertNil(cache.image(from: Data()))
        XCTAssertNil(cache.image(from: Data("not an image".utf8)))
        XCTAssertNil(cache.image(from: Data(), maxPixelSize: 0))
    }

    // 本物の個人写真を使わず、メモリ上に作ったJPEGで検証します。
    private func jpeg(width: Int, height: Int, orientation: Int = 1) throws -> Data {
        let context = try XCTUnwrap(CGContext(data: nil, width: width, height: height,
                                             bitsPerComponent: 8, bytesPerRow: width * 4,
                                             space: CGColorSpaceCreateDeviceRGB(),
                                             bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue))
        context.setFillColor(CGColor(red: 0.4, green: 0.6, blue: 0.5, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let image = try XCTUnwrap(context.makeImage())
        let output = NSMutableData()
        let destination = try XCTUnwrap(CGImageDestinationCreateWithData(output, "public.jpeg" as CFString, 1, nil))
        CGImageDestinationAddImage(destination, image, [kCGImagePropertyOrientation: orientation] as CFDictionary)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        return output as Data
    }
}
