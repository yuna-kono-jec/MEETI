import Foundation
import CoreData

// iOS 16専用の新しい保存領域。SwiftDataのdefault.storeを開いたり、削除したりしません。
@MainActor
final class CoreDataParticipantStorage: ParticipantStorage {
    private let context: NSManagedObjectContext

    init(inMemory: Bool = false, url: URL) throws {
        // モデル名とファイルを独立させ、既存SwiftDataとの暗黙的な移行を防ぎます。
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "LocalParticipant"
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        func attribute(_ name: String, _ type: NSAttributeType, optional: Bool = false) -> NSAttributeDescription {
            let value = NSAttributeDescription()
            value.name = name
            value.attributeType = type
            value.isOptional = optional
            return value
        }
        let photo = attribute("photoData", .binaryDataAttributeType, optional: true)
        photo.allowsExternalBinaryDataStorage = true
        entity.properties = [
            attribute("remoteID", .UUIDAttributeType, optional: true),
            attribute("number", .integer64AttributeType),
            attribute("nickname", .stringAttributeType),
            attribute("mbti", .stringAttributeType),
            attribute("interestsData", .binaryDataAttributeType),
            attribute("message", .stringAttributeType),
            attribute("gender", .stringAttributeType),
            attribute("ageGroup", .stringAttributeType), photo,
            attribute("webPhotoPath", .stringAttributeType, optional: true),
            attribute("webPhotoToken", .stringAttributeType, optional: true),
            attribute("createdAt", .dateAttributeType)
        ]
        model.entities = [entity]
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        if !inMemory {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        }
        // 初回または同じモデルを開くのみ。失敗時にDBを消すフォールバックは設けません。
        try coordinator.addPersistentStore(ofType: inMemory ? NSInMemoryStoreType : NSSQLiteStoreType,
                                           configurationName: nil, at: inMemory ? nil : url, options: nil)
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
    }

    func save(_ participant: ParticipantProfile) throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: "LocalParticipant")
        // 更新はremoteID優先。古いローカル参加者は受付番号とremoteID=nilで区別します。
        if let id = participant.remoteID {
            request.predicate = NSPredicate(format: "remoteID == %@", id as NSUUID)
        } else {
            request.predicate = NSPredicate(format: "remoteID == nil AND number == %lld", Int64(participant.number))
        }
        request.fetchLimit = 1
        // エンコード失敗なら既存の行を変更しません。
        let interests = try JSONEncoder().encode(participant.interests)
        let row = try context.fetch(request).first ?? NSEntityDescription.insertNewObject(forEntityName: "LocalParticipant", into: context)
        row.setValue(participant.remoteID, forKey: "remoteID")
        row.setValue(Int64(participant.number), forKey: "number")
        row.setValue(participant.nickname, forKey: "nickname")
        row.setValue(participant.mbti, forKey: "mbti")
        row.setValue(interests, forKey: "interestsData")
        row.setValue(participant.message, forKey: "message")
        row.setValue(participant.gender, forKey: "gender")
        row.setValue(participant.ageGroup, forKey: "ageGroup")
        row.setValue(participant.photoData, forKey: "photoData")
        row.setValue(participant.webPhotoPath, forKey: "webPhotoPath")
        row.setValue(participant.webPhotoToken, forKey: "webPhotoToken")
        row.setValue(participant.createdAt, forKey: "createdAt")
        do { try context.save() } catch { context.rollback(); throw error }
    }

    func fetchAll() throws -> [ParticipantProfile] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "LocalParticipant")
        request.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        return try context.fetch(request).map { row in
            let interests = try JSONDecoder().decode([String].self, from: row.value(forKey: "interestsData") as! Data)
            let profile = ParticipantProfile(number: Int(row.value(forKey: "number") as! Int64),
                nickname: row.value(forKey: "nickname") as! String,
                mbti: row.value(forKey: "mbti") as! String, interests: interests,
                message: row.value(forKey: "message") as! String,
                gender: row.value(forKey: "gender") as! String,
                ageGroup: row.value(forKey: "ageGroup") as! String,
                photoData: row.value(forKey: "photoData") as? Data,
                createdAt: row.value(forKey: "createdAt") as! Date)
            profile.remoteID = row.value(forKey: "remoteID") as? UUID
            profile.webPhotoPath = row.value(forKey: "webPhotoPath") as? String
            profile.webPhotoToken = row.value(forKey: "webPhotoToken") as? String
            return profile
        }
    }

    func delete(remoteID: UUID) throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: "LocalParticipant")
        request.predicate = NSPredicate(format: "remoteID == %@", remoteID as NSUUID)
        for row in try context.fetch(request) { context.delete(row) }
        do { try context.save() } catch { context.rollback(); throw error }
    }
}
