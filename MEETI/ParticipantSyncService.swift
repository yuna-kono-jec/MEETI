import Foundation
import Supabase

// 複数の端末で同じ参加者データを使うための処理
enum ParticipantSyncService {
    private static let tableName = "participants"
    private static let photoBucketName = "meeti-photos"

    // 取得済みの写真は使い回す
    @MainActor
    private static let photoCache: NSCache<NSString, NSData> = {
        let cache = NSCache<NSString, NSData>()
        cache.totalCostLimit = 20 * 1024 * 1024
        return cache
    }()

    @MainActor
    static func fetchPhoto(path: String) async throws -> Data {
        if let cached = photoCache.object(forKey: path as NSString) {
            return cached as Data
        }

        try await prepareSession()

        let data = try await SupabaseService.client.storage
            .from(photoBucketName)
            .download(path: path)

        photoCache.setObject(
            data as NSData,
            forKey: path as NSString,
            cost: data.count
        )

        return data
    }


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

        @MainActor
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
        var stage = "認証"

        do {
            print("MEETI: \(stage)開始")
            try await prepareSession()
            print("MEETI: 認証成功")

            // 写真があるときだけ先にStorageへ送る
            var photoPath: String?
            if let photoData {
                stage = "写真保存"
                print("MEETI: \(stage)開始")

                photoPath = try await PhotoUploadService.uploadPhoto(
                    photoData: photoData
                )

                print("MEETI: 写真保存成功")
            } else {
                print("MEETI: 写真なし")
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

            stage = "参加者保存・応答読み取り"
            print("MEETI: \(stage)開始")

            let row: ParticipantRow = try await SupabaseService.client
                .from(tableName)
                .insert(newRow)
                .select()
                .single()
                .execute()
                .value

            print("MEETI: 参加者保存・応答読み取り成功")
            return row.makeParticipant(photoData: photoData)

        } catch {
            print("MEETI: \(stage)で失敗")
            print(String(reflecting: error))
            throw error
        }
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

        // 人数が多いときは、ときどき画面操作に処理を譲る
        var participants: [Participant] = []
        participants.reserveCapacity(rows.count)
        for (index, row) in rows.enumerated() {
            if index.isMultiple(of: 25) {
                await Task.yield()
                try Task.checkCancellation()
            }
            participants.append(row.makeParticipant())
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

    // 日付を読む道具を、参加者ごとに作り直さない
    @MainActor
    private static let fractionalDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    @MainActor
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    @MainActor
    private static func date(from text: String) -> Date {
        fractionalDateFormatter.date(from: text) ?? dateFormatter.date(from: text) ?? Date()
    }
}
