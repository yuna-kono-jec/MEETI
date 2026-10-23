import XCTest
import ImageIO
@testable import MEETILogic

// 縮小した写真の向き・縦横比・再利用を確認する
final class PhotoThumbnailTests: XCTestCase {
    @MainActor
    func testDownsamplesAndReusesDecodedImage() async throws {
        let data = try jpeg(width: 2400, height: 1800)
        let cache = PhotoThumbnail()
        let firstResult = await cache.image(from: data)
        let first = try XCTUnwrap(firstResult)
        XCTAssertEqual(first.width, 1024)
        XCTAssertEqual(first.height, 768)
        let cached = await cache.image(from: data)
        XCTAssertTrue(first === cached)
        let smallerResult = await cache.image(from: data, maxPixelSize: 512)
        let smaller = try XCTUnwrap(smallerResult)
        XCTAssertEqual(smaller.width, 512)
        XCTAssertEqual(smaller.height, 384)
    }

    @MainActor
    func testAppliesCameraOrientation() async throws {
        let data = try jpeg(width: 1200, height: 800, orientation: 6)
        let result = await PhotoThumbnail().image(from: data, maxPixelSize: 600)
        let image = try XCTUnwrap(result)
        XCTAssertEqual(image.width, 400)
        XCTAssertEqual(image.height, 600)
    }

    @MainActor
    func testDifferentPhotosDoNotShareCachedImage() async throws {
        let cache = PhotoThumbnail()
        let firstData = try jpeg(width: 60, height: 40)
        let secondData = try jpeg(width: 40, height: 60)
        let firstResult = await cache.image(from: firstData)
        let secondResult = await cache.image(from: secondData)
        let first = try XCTUnwrap(firstResult)
        let second = try XCTUnwrap(secondResult)
        XCTAssertFalse(first === second)
        XCTAssertEqual(second.height, 60)
    }

    // バックグラウンドでも縦写真の向きと比率を保つ
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
    func testInvalidInputFallsBackWithoutCrashing() async {
        let cache = PhotoThumbnail()
        let empty = await cache.image(from: Data())
        let invalid = await cache.image(from: Data("not an image".utf8))
        let zeroSize = await cache.image(from: Data(), maxPixelSize: 0)
        XCTAssertNil(empty)
        XCTAssertNil(invalid)
        XCTAssertNil(zeroSize)
    }

    @MainActor
    func testCancelledRequestDoesNotReturnOldPhoto() async throws {
        let data = try jpeg(width: 2400, height: 1800)
        let cache = PhotoThumbnail()
        // 同じ写真がキャッシュにあってもキャンセルを優先する
        let warmed = await cache.image(from: data)
        XCTAssertNotNil(warmed)
        let task = Task { await cache.image(from: data) }
        task.cancel()
        let result = await task.value
        XCTAssertNil(result)
    }

    @MainActor
    func testOtherMainActorWorkRunsWhilePreparingPhoto() async throws {
        let data = try jpeg(width: 4032, height: 3024)
        let cache = PhotoThumbnail()
        var photoFinished = false
        let preparation = Task {
            let image = await cache.image(from: data)
            photoFinished = true
            return image
        }
        // 先に始まった画像処理がメインアクターを独占していないか確認する
        let otherWork = Task { !photoFinished }
        let ranBeforePhotoFinished = await otherWork.value
        let image = await preparation.value
        XCTAssertTrue(ranBeforePhotoFinished)
        XCTAssertNotNil(image)
    }

    // 個人写真を使わず、テスト用のJPEGをメモリ上で作る
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
