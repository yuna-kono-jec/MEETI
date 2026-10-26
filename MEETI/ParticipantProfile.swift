import Foundation
import Combine

// iOS 16の画面・通信・計算用モデル。既存SwiftDataのParticipant型は変更・移行しません。
// 更新操作は画面・Store・通信サービスのMainActorから行い、計算では値を読むだけにします。
final class ParticipantProfile: ObservableObject {
    @Published var remoteID: UUID?
    @Published var number: Int
    @Published var nickname: String
    @Published var mbti: String
    @Published var interests: [String]
    @Published var message: String
    @Published var gender: String
    @Published var ageGroup: String
    @Published var photoData: Data?
    @Published var webPhotoPath: String?
    @Published var webPhotoToken: String?
    @Published var createdAt: Date

    init(number: Int, nickname: String, mbti: String, interests: [String], message: String,
         gender: String = "未回答", ageGroup: String = "未回答", photoData: Data? = nil,
         createdAt: Date = Date()) {
        self.number = number
        self.nickname = nickname
        self.mbti = mbti
        self.interests = interests
        self.message = message
        self.gender = gender
        self.ageGroup = ageGroup
        self.photoData = photoData
        self.createdAt = createdAt
    }
}

// 保存層はこの共通操作だけを公開し、画面へCore Data/SwiftDataの詳細を持ち出しません。
@MainActor
protocol ParticipantStorage {
    func save(_ participant: ParticipantProfile) throws
    func fetchAll() throws -> [ParticipantProfile]
    func delete(remoteID: UUID) throws
}
