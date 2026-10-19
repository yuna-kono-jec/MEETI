import Foundation
import Supabase

// 複数の端末で同じ参加者データを使うための処理
enum ParticipantSyncService {
    private static let tableName = "participants"
    private static let photoBucketName = "meeti-photos"

    // Supabaseへ新しく送る参加者データ
    private struct NewParticipantRow: Encodable {
        let nickname: String
        let mbti: String
        let interests: [String]
        let message: String
        let gender: String
        let ageGroup: String
        let photoPath: String?

        enum CodingKeys: String, CodingKey {
            case nickname
            case mbti
            case interests
            case message
            case gender
            case ageGroup = "age_group"
            case photoPath = "photo_path"
        }
    }

    // Supabaseから受け取る参加者データ
    private struct ParticipantRow: Decodable {
        let id: UUID
        let number: Int
        let nickname: String
        let mbti: String
        let interests: [String]
        let message: String
        let gender: String
        let ageGroup: String
        let photoPath: String?
        let createdAt: String

        enum CodingKeys: String, CodingKey {
            case id
            case number
            case nickname
            case mbti
            case interests
            case message
            case gender
            case ageGroup = "age_group"
            case photoPath = "photo_path"
            case createdAt = "created_at"
        }

        func makeParticipant(photoData: Data? = nil) -> Participant {
            let participant = Participant(
                number: number,
                nickname: nickname,
                mbti: mbti,
                interests: interests,
                message: message,
                gender: gender,
                ageGroup: ageGroup,
                photoData: photoData,
                createdAt: ParticipantSyncService.date(from: createdAt)
            )
            participant.remoteID = id
            participant.webPhotoPath = photoPath
            return participant
        }
    }

    @MainActor
    static func saveParticipant(
        nickname: String,
        mbti: String,
        interests: [String],
        message: String,
        gender: String,
        ageGroup: String,
        photoData: Data?
    ) async throws -> Participant {
        try await prepareSession()

        // 写真があるときだけ先にStorageへ送る
        var photoPath: String?
        if let photoData {
            photoPath = try await PhotoUploadService.uploadPhoto(
                photoData: photoData
            )
        }

        let newRow = NewParticipantRow(
            nickname: nickname,
            mbti: mbti,
            interests: interests,
            message: message,
            gender: gender,
            ageGroup: ageGroup,
            photoPath: photoPath
        )

        // Supabase側で全端末共通の受付番号を付けてもらう
        let row: ParticipantRow = try await SupabaseService.client
            .from(tableName)
            .insert(newRow)
            .select()
            .single()
            .execute()
            .value

        return row.makeParticipant(photoData: photoData)
    }

    @MainActor
    static func fetchParticipants() async throws -> [Participant] {
        try await prepareSession()

        let rows: [ParticipantRow] = try await SupabaseService.client
            .from(tableName)
            .select()
            .order("number", ascending: true)
            .execute()
            .value

        var participants: [Participant] = []

        for row in rows {
            var photoData: Data?

            // 写真を取れないときはMBTI画像を使うので、参加者データは残す
            if let photoPath = row.photoPath {
                photoData = try? await SupabaseService.client.storage
                    .from(photoBucketName)
                    .download(path: photoPath)
            }

            participants.append(row.makeParticipant(photoData: photoData))
        }

        return participants
    }

    @MainActor
    private static func prepareSession() async throws {
        // 運営ログイン済みなら今のログインをそのまま使う
        if (try? await SupabaseService.client.auth.session) != nil {
            return
        }

        // 未ログインの実機は匿名ユーザーとして接続する
        _ = try await SupabaseService.client.auth.signInAnonymously()
    }

    private static func date(from text: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: text) {
            return date
        }

        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: text) ?? Date()
    }
}
