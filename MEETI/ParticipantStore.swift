import Foundation
import Combine

// 体験の終了・画面再作成とは独立して生存する、保存操作の共通窓口です。
@MainActor
final class ParticipantStore: ObservableObject {
    private let storage: any ParticipantStorage
    let usesCoreData: Bool

    init(inMemory: Bool = false, forceCoreData: Bool = false,
         coreDataURL: URL? = nil, legacyURL: URL? = nil) throws {
        let support = try FileManager.default.url(for: .applicationSupportDirectory,
                                                in: .userDomainMask, appropriateFor: nil, create: false)
        let url = coreDataURL ?? support.appendingPathComponent("MEETI-iOS16/participants.sqlite")
        // iOS 16で作ったStoreはOS更新後も同じものを使用し、暗黙の移行・データの見失いを防ぎます。
        if forceCoreData || (!inMemory && FileManager.default.fileExists(atPath: url.path)) {
            storage = try CoreDataParticipantStorage(inMemory: inMemory, url: url)
            usesCoreData = true
        } else if #available(iOS 17, macOS 14, *) {
            storage = try SwiftDataParticipantStorage(inMemory: inMemory, url: legacyURL)
            usesCoreData = false
        } else {
            storage = try CoreDataParticipantStorage(inMemory: inMemory, url: url)
            usesCoreData = true
        }
    }

    // 失敗時には例外を呼び出し画面へ返し、別の空DBへ切り替えません。
    func save(_ participant: ParticipantProfile) throws { try storage.save(participant) }
    func fetchAll() throws -> [ParticipantProfile] { try storage.fetchAll() }
    func delete(remoteID: UUID) throws { try storage.delete(remoteID: remoteID) }
}
