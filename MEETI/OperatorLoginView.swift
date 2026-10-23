//
//  OperatorLoginView.swift
//  MEETI
//
//  Created by cmStudent on 2026/10/16.
//

import SwiftUI
import Supabase

struct OperatorLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var statusMessage = ""
    @State private var loginSucceeded = false
    @State private var isUploading = false
    @State private var uploadMessage = ""
    @State private var testCardURL: URL?

    var body: some View {
        Form {
            Section("運営用ログイン") {
                TextField("メールアドレス", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                SecureField("パスワード", text: $password)
                    .textContentType(.password)

                Button {
                    Task {
                        await signIn()
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("ログイン")
                    }
                }
                .disabled(
                    isLoading ||
                    loginSucceeded ||
                    email.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty ||
                    password.isEmpty
                )
            }
            .disabled(isLoading || loginSucceeded)

            if !statusMessage.isEmpty {
                Section {
                    Text(statusMessage)
                }
            }
            if loginSucceeded {
                Section("名刺の管理") {
                    NavigationLink {
                        OperatorParticipantsView()
                    } label: {
                        Text("登録済み名刺を確認・削除")
                    }
                }

                Section("アップロード確認") {
                    Button {
                        Task {
                            await uploadTestImage()
                        }
                    } label: {
                        if isUploading {
                            ProgressView()
                        } else {
                            Text("テスト画像を送信")
                        }
                    }
                    .disabled(isUploading)

                    if !uploadMessage.isEmpty {
                        Text(uploadMessage)
                    }
                    if let url = testCardURL {
                        Link("写真付きWeb名刺を開く", destination: url)
                    }
                }
            }
        }
        .navigationTitle("運営用")
    }

    @MainActor
    private func signIn() async {
        isLoading = true
        statusMessage = ""

        defer {
            isLoading = false
        }

        do {
            _ = try await SupabaseService.client.auth.signIn(
                email: email.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                password: password
            )

            password = ""
            loginSucceeded = true
            statusMessage = "ログインに成功しました。"
        } catch {
            statusMessage =
                "ログインできませんでした。入力内容と通信環境を確認してください。"
        }
    }
}

extension OperatorLoginView {
    @MainActor
    private func uploadTestImage() async {
        isUploading = true
        uploadMessage = ""
        testCardURL = nil

        defer {
            isUploading = false
        }

        do {
            // 新しい緑色の仮画像をアップロード
            let path = try await PhotoUploadService.uploadTestImage()

            // サーバーで共有登録し、トークンを受け取る
            let registration =
                try await PhotoUploadService.registerPhoto(
                    objectPath: path
                )

            var components = URLComponents(
                string:
                    "https://yuna-kono-jec.github.io/MEETI/MEETI/WebCard/"
            )

            components?.queryItems = [
                URLQueryItem(name: "name", value: "TEST"),
                URLQueryItem(name: "mbti", value: "INFP"),
                URLQueryItem(name: "number", value: "37")
            ]

            components?.fragment =
                "photoToken=\(registration.photoToken)"

            guard let url = components?.url else {
                uploadMessage =
                    "共有登録は成功しましたが、名刺URLを作成できませんでした。"
                return
            }

            testCardURL = url
            uploadMessage = "画像の送信と共有登録に成功しました。"
        } catch {
            uploadMessage =
                "送信または共有登録に失敗しました：\(error.localizedDescription)"
        }
    }
}

#Preview {
    NavigationStack {
        OperatorLoginView()
    }
}
