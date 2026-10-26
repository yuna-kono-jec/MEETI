import XCTest
import SwiftData
@testable import MEETILogic

// 全てメモリ上か専用の一時フォルダで実行し、アプリの実保存データは開きません。
@MainActor
final class ParticipantStoreTests: XCTestCase {
    func testCoreDataRoundTripAndReopen() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("participants.sqlite")
        let profile = sample()
        do {
            let store = try ParticipantStore(forceCoreData: true, coreDataURL: url)
            try store.save(profile)
        }
        // 再起動相当。新しいOSでも既存のCore Data領域を自動で乗り換えません。
        let reopened = try ParticipantStore(coreDataURL: url)
        XCTAssertTrue(reopened.usesCoreData)
        let saved = try XCTUnwrap(reopened.fetchAll().first)
        assertEqual(saved, profile)
    }

    func testBothBackendsUpdateWithoutDuplicatingAndDeleteOnlyRemoteID() throws {
        for coreData in [true, false] {
            let store = try ParticipantStore(inMemory: true, forceCoreData: coreData)
            let first = sample()
            let other = sample()
            other.number = 2
            try store.save(first)
            try store.save(other)
            first.webPhotoPath = "new-path"
            first.webPhotoToken = "new-token"
            try store.save(first)
            let all = try store.fetchAll()
            XCTAssertEqual(all.count, 2)
            XCTAssertEqual(all.first?.webPhotoToken, "new-token")
            try store.delete(remoteID: first.remoteID!)
            XCTAssertEqual(try store.fetchAll().map(\.remoteID), [other.remoteID])
        }
    }

    func testNilRemoteIDRecordsAreRetainedAndNotDeletedByAnotherID() throws {
        for coreData in [true, false] {
            let store = try ParticipantStore(inMemory: true, forceCoreData: coreData)
            let profile = sample()
            profile.remoteID = nil
            try store.save(profile)
            profile.message = "更新"
            try store.save(profile)
            try store.delete(remoteID: UUID())
            XCTAssertEqual(try store.fetchAll().count, 1)
            XCTAssertEqual(try store.fetchAll().first?.message, "更新")
        }
    }

    // 保存層を通した後も、自分の除外・希望条件・同率1位の複数表示を両方式で確認します。
    func testStoredMatchingPreservesSelfExclusionFiltersAndTies() throws {
        for coreData in [true, false] {
            let store = try ParticipantStore(inMemory: true, forceCoreData: coreData)
            let me = sample()
            let first = sample(); first.number = 2
            let second = sample(); second.number = 3
            let excluded = sample(); excluded.number = 4; excluded.gender = "男性"
            for profile in [me, first, second, excluded] { try store.save(profile) }
            let result = BestMatchCalculator.findBestMatches(participant: me, participantStore: store,
                preferredGender: "女性", preferredAgeGroup: "20〜29歳")
            XCTAssertEqual(Set(result?.matches.map { $0.participant.number } ?? []), Set([2, 3]))
            XCTAssertEqual(result?.score, 100)
        }
    }

    func testExistingSwiftDataStoreOpensWithoutMigration() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("legacy.store")
        let remoteID = UUID()
        // 旧アプリと同じParticipantスキーマで事前データを作ります。
        do {
            let schema = Schema([Participant.self])
            let container = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, url: url)])
            let profile = Participant(number: 7, nickname: "旧参加者", mbti: "INFP", interests: ["読書"], message: "保持")
            profile.remoteID = remoteID
            profile.photoData = Data([1, 2, 3])
            profile.webPhotoPath = "legacy-path"
            profile.webPhotoToken = "legacy-token"
            container.mainContext.insert(profile)
            try container.mainContext.save()
        }
        let store = try ParticipantStore(coreDataURL: folder.appendingPathComponent("unused.sqlite"), legacyURL: url)
        XCTAssertFalse(store.usesCoreData)
        let saved = try XCTUnwrap(store.fetchAll().first)
        XCTAssertEqual(saved.remoteID, remoteID)
        XCTAssertEqual(saved.photoData, Data([1, 2, 3]))
        XCTAssertEqual(saved.webPhotoPath, "legacy-path")
        XCTAssertEqual(saved.webPhotoToken, "legacy-token")
        saved.message = "更新後"
        try store.save(saved)
        XCTAssertEqual(try store.fetchAll().count, 1)
        XCTAssertEqual(try store.fetchAll().first?.message, "更新後")
    }

    func testFailureDoesNotOverwriteExistingFileOrCreateFallback() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("participants.sqlite")
        let marker = Data("not a database".utf8)
        try marker.write(to: url)
        XCTAssertThrowsError(try ParticipantStore(forceCoreData: true, coreDataURL: url))
        XCTAssertEqual(try Data(contentsOf: url), marker)
    }

    private func sample() -> ParticipantProfile {
        let profile = ParticipantProfile(number: 1, nickname: "テスト", mbti: "ENFJ",
            interests: ["音楽", "旅行", "猫"], message: "よろしく", gender: "女性",
            ageGroup: "20〜29歳", photoData: Data([1, 3, 5]), createdAt: Date(timeIntervalSince1970: 100))
        profile.remoteID = UUID()
        profile.webPhotoPath = "photo-path"
        profile.webPhotoToken = "photo-token"
        return profile
    }

    private func assertEqual(_ first: ParticipantProfile, _ second: ParticipantProfile) {
        XCTAssertEqual(first.remoteID, second.remoteID)
        XCTAssertEqual(first.number, second.number)
        XCTAssertEqual(first.nickname, second.nickname)
        XCTAssertEqual(first.mbti, second.mbti)
        XCTAssertEqual(first.interests, second.interests)
        XCTAssertEqual(first.message, second.message)
        XCTAssertEqual(first.gender, second.gender)
        XCTAssertEqual(first.ageGroup, second.ageGroup)
        XCTAssertEqual(first.photoData, second.photoData)
        XCTAssertEqual(first.webPhotoPath, second.webPhotoPath)
        XCTAssertEqual(first.webPhotoToken, second.webPhotoToken)
        XCTAssertEqual(first.createdAt, second.createdAt)
    }
}
