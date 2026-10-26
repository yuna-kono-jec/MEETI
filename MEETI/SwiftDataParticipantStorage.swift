import Foundation
import SwiftData

// iOS 17以降では従来のParticipantと保存領域をそのまま使い、データ移行を行いません。
@available(iOS 17, macOS 14, *)
@MainActor
final class SwiftDataParticipantStorage: ParticipantStorage {
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    init(inMemory: Bool = false, url: URL? = nil) throws {
        let schema = Schema([Participant.self])
        // URL未指定時は旧MEETIAppと同じ構成・デフォルトの保存先です。
        let configuration: ModelConfiguration
        if let url {
            configuration = ModelConfiguration(schema: schema, url: url)
        } else {
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        }
        container = try ModelContainer(for: schema, configurations: [configuration])
    }

    func save(_ profile: ParticipantProfile) throws {
        let descriptor: FetchDescriptor<Participant>
        if let id = profile.remoteID {
            descriptor = FetchDescriptor(predicate: #Predicate { $0.remoteID == id })
        } else {
            let number = profile.number
            descriptor = FetchDescriptor(predicate: #Predicate { $0.remoteID == nil && $0.number == number })
        }
        let record: Participant
        if let existing = try context.fetch(descriptor).first {
            record = existing
        } else {
            record = Participant(number: profile.number, nickname: profile.nickname, mbti: profile.mbti,
                                 interests: profile.interests, message: profile.message)
            context.insert(record)
        }
        // 元写真、公開用のパス・トークン、作成日時を欠かさず保存します。
        record.remoteID = profile.remoteID
        record.number = profile.number
        record.nickname = profile.nickname
        record.mbti = profile.mbti
        record.interests = profile.interests
        record.message = profile.message
        record.gender = profile.gender
        record.ageGroup = profile.ageGroup
        record.photoData = profile.photoData
        record.webPhotoPath = profile.webPhotoPath
        record.webPhotoToken = profile.webPhotoToken
        record.createdAt = profile.createdAt
        do { try context.save() } catch { context.rollback(); throw error }
    }

    func fetchAll() throws -> [ParticipantProfile] {
        let records = try context.fetch(FetchDescriptor<Participant>(sortBy: [SortDescriptor(\.number)]))
        return records.map { record in
            let profile = ParticipantProfile(number: record.number, nickname: record.nickname, mbti: record.mbti,
                interests: record.interests, message: record.message, gender: record.gender,
                ageGroup: record.ageGroup, photoData: record.photoData, createdAt: record.createdAt)
            profile.remoteID = record.remoteID
            profile.webPhotoPath = record.webPhotoPath
            profile.webPhotoToken = record.webPhotoToken
            return profile
        }
    }

    func delete(remoteID: UUID) throws {
        let records = try context.fetch(FetchDescriptor<Participant>(predicate: #Predicate { $0.remoteID == remoteID }))
        for record in records { context.delete(record) }
        do { try context.save() } catch { context.rollback(); throw error }
    }
}
