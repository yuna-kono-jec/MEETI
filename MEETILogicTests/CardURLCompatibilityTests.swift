import XCTest
@testable import MEETILogic

// 保存方式が変わっても、既存Web名刺のURLと写真トークンの公開条件を維持します。
@MainActor
final class CardURLCompatibilityTests: XCTestCase {
    func testURLRemainsIdenticalAfterBothStorageRoundTrips() throws {
        for coreData in [true, false] {
            let store = try ParticipantStore(inMemory: true, forceCoreData: coreData)
            let profile = ParticipantProfile(number: 11, nickname: "ゆな & 花", mbti: "INFP",
                interests: ["読書", "音楽", "旅行"], message: "よろしく！ #会話")
            profile.remoteID = UUID()
            profile.webPhotoToken = String(repeating: "a", count: 64)
            let before = try XCTUnwrap(CardURLBuilder.makeURL(from: profile))
            try store.save(profile)
            let saved = try XCTUnwrap(store.fetchAll().first)
            XCTAssertEqual(CardURLBuilder.makeURL(from: saved), before)
            let components = try XCTUnwrap(URLComponents(url: before, resolvingAgainstBaseURL: false))
            XCTAssertEqual(components.queryItems?.map(\.name), ["number", "name", "mbti", "interests", "message"])
            XCTAssertEqual(components.queryItems?[1].value, profile.nickname)
            XCTAssertEqual(components.fragment, "photoToken=\(profile.webPhotoToken!)")
            // 規定外のトークンは従来どおりQRのURLに載せません。
            saved.webPhotoToken = "invalid"
            XCTAssertNil(CardURLBuilder.makeURL(from: saved)?.fragment)
        }
    }
}
