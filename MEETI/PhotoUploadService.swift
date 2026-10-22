//
//  PhotoUploadService.swift
//  MEETI
//
//  Created by cmStudent on 2026/10/17.
//

import Foundation
import UIKit
import Supabase

enum PhotoUploadService {
    @MainActor
    static func uploadTestImage() async throws -> String {
        // ログインしている運営アカウントを取得
        let session = try await SupabaseService.client.auth.session
        let userID = session.user.id.uuidString.lowercased()

        // 顔写真の代わりに、小さな仮画像を作成
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: 200, height: 200)
        )

        let image = renderer.image { context in
            UIColor.systemGreen.setFill()
            context.fill(
                CGRect(x: 0, y: 0, width: 200, height: 200)
            )
        }

        guard let data = image.jpegData(
            compressionQuality: 0.8
        ) else {
            throw UploadError.imageCreationFailed
        }

        // 毎回別の名前にして、既存の写真を上書きしない
        let fileName = "test-\(UUID().uuidString.lowercased()).jpg"
        let path = "\(userID)/\(fileName)"

        _ = try await SupabaseService.client.storage
            .from("meeti-photos")
            .upload(
                path: path,
                file: data,
                options: FileOptions(
                    contentType: "image/jpeg",
                    upsert: false
                )
            )

        return path
    }

    enum UploadError: LocalizedError {
        case imageCreationFailed

        var errorDescription: String? {
            "テスト画像を作成できませんでした。"
        }
    }
}

extension PhotoUploadService {
    struct RegistrationResponse: Decodable {
        let photoToken: String
        let expiresAt: String
    }

    @MainActor
    static func registerPhoto(
        objectPath: String
    ) async throws -> RegistrationResponse {
        let session = try await SupabaseService.client.auth.session

        let result: RegistrationResponse =
            try await SupabaseService.client.functions.invoke(
                "meeti-register-photo",
                options: FunctionInvokeOptions(
                    headers: [
                        "Authorization": "Bearer \(session.accessToken)"
                    ],
                    body: [
                        "objectPath": objectPath
                    ]
                )
            )

        return result
    }
}

extension PhotoUploadService {
    @MainActor
    static func uploadPhoto(photoData: Data) async throws -> String {
        let session = try await SupabaseService.client.auth.session
        let userID = session.user.id.uuidString.lowercased()

        // JPEGの再描画・圧縮だけをバックグラウンドへ移し、操作を処理するメインスレッドを空けます。
        // 圧縮率・1024px上限・容量制限・メタデータ除去は変更しません。
        let jpegData = try await Task.detached(priority: .userInitiated) {
            try prepareJPEG(from: photoData)
        }.value

        let fileName = "photo-\(UUID().uuidString.lowercased()).jpg"
        let path = "\(userID)/\(fileName)"

        _ = try await SupabaseService.client.storage
            .from("meeti-photos")
            .upload(
                path: path,
                file: jpegData,
                options: FileOptions(
                    contentType: "image/jpeg",
                    upsert: false
                )
            )

        return path
    }

    // UIと独立した画像変換なので、呼び出し元のメインアクターへ戻さず実行します。
    nonisolated private static func prepareJPEG(from data: Data) throws -> Data {
        guard let original = UIImage(data: data),
              original.size.width > 0,
              original.size.height > 0 else {
            throw PhotoError.invalidImage
        }

        // 長い辺を最大1024ピクセルにする
        var maxSide: CGFloat = 1024

        while maxSide >= 256 {
            let ratio = min(
                1,
                maxSide / max(
                    original.size.width,
                    original.size.height
                )
            )

            let size = CGSize(
                width: max(1, floor(original.size.width * ratio)),
                height: max(1, floor(original.size.height * ratio))
            )

            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            format.opaque = true

            let renderer = UIGraphicsImageRenderer(
                size: size,
                format: format
            )

            // 再描画して、元写真の位置情報などを引き継がない
            let resized = renderer.image { context in
                UIColor.white.setFill()
                context.fill(CGRect(origin: .zero, size: size))
                original.draw(in: CGRect(origin: .zero, size: size))
            }

            for quality in [0.8, 0.6, 0.4, 0.2] {
                if let jpeg = resized.jpegData(
                    compressionQuality: CGFloat(quality)
                ), jpeg.count <= 2_000_000 {
                    return jpeg
                }
            }

            maxSide /= 2
        }

        throw PhotoError.imageTooLarge
    }

    enum PhotoError: LocalizedError {
        case invalidImage
        case imageTooLarge

        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "写真を読み込めませんでした。"
            case .imageTooLarge:
                return "写真をアップロードできるサイズに縮小できませんでした。"
            }
        }
    }
}
