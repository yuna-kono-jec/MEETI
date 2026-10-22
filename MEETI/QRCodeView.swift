//
//  QRCodeView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI
import SwiftData

struct QRCodeView: View {
    @Environment(\.finishMEETIExperience)
    private var finishExperience

    @Environment(\.modelContext)
    private var modelContext

    var participant: Participant

    @State private var cardURL: URL?
    // QRはURLが確定した時だけ生成し、bodyの再評価では完成画像を再利用します。
    @State private var qrImage: UIImage?
    @State private var isPreparing = false
    @State private var preparationStarted = false
    @State private var errorMessage: String?

    var body: some View {
        MEETIScreen(
            eyebrow: "08 / TAKE AWAY",
            title: "名刺を持ち帰ろう",
            subtitle: "今日の出会いを、これからも。"
        ) {
            VStack(spacing: 24) {
                if isPreparing {
                    ProgressView("名刺を準備しています…")

                } else if let errorMessage {
                    Text(errorMessage)
                        .multilineTextAlignment(.center)

                    Button("もう一度試す") {
                        Task {
                            await prepareCard()
                        }
                    }
                    .buttonStyle(MEETIButtonStyle())

                } else if cardURL != nil {
                    if let qrImage {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .padding(20)
                            .background(Color.white)

                        Text("自分のスマホのカメラで読み取ってね")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("QRコードを作成できませんでした。")
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .meetiCard()

            MEETIParticipantCard(participant: participant)

            VStack(spacing: 12) {
                Text("名刺を保存したら、次の人へ")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button {
                    finishExperience?()
                } label: {
                    HStack {
                        Spacer()
                        Text("体験を終了する")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(MEETIButtonStyle())
                .disabled(
                    finishExperience == nil || isPreparing
                )
            }
            .frame(maxWidth: .infinity)
        }
        .task {
            guard !preparationStarted else { return }
            preparationStarted = true
            await prepareCard()
        }
    }

    @MainActor
    private func prepareCard() async {
        guard !isPreparing else { return }

        isPreparing = true
        errorMessage = nil
        cardURL = nil
        qrImage = nil

        defer {
            isPreparing = false
        }

        do {
            guard let publicEnd = ISO8601DateFormatter().date(
                from: "2026-11-09T00:00:00+09:00"
            ) else {
                errorMessage = "公開期限の設定を確認してください。"
                return
            }

            // 写真あり・公開期間内・トークン未取得の場合だけ送信
            if let photoData = participant.photoData,
               Date() < publicEnd,
               participant.webPhotoToken == nil {

                let path: String

                if let savedPath = participant.webPhotoPath {
                    // すでに送信済みなら同じ保存先を再利用
                    path = savedPath
                } else {
                    path = try await PhotoUploadService.uploadPhoto(
                        photoData: photoData
                    )

                    participant.webPhotoPath = path
                    try modelContext.save()
                }

                let registration =
                    try await PhotoUploadService.registerPhoto(
                        objectPath: path
                    )

                participant.webPhotoToken =
                    registration.photoToken
            }

            // 保存できたことを確認してからQRを表示
            try modelContext.save()

            guard let url = CardURLBuilder.makeURL(
                from: participant
            ) else {
                errorMessage = "名刺URLを作成できませんでした。"
                return
            }

            qrImage = QRCodeGenerator.generate(from: url.absoluteString)
            cardURL = url

        } catch {
            errorMessage =
                "名刺の準備に失敗しました。運営用ログインと通信環境を確認してください。\n\(error.localizedDescription)"
        }
    }
}

#Preview {
    NavigationStack {
        QRCodeView(
            participant: Participant(
                number: 1,
                nickname: "ゆな",
                mbti: "ENTJ",
                interests: ["ゲーム", "犬", "旅行"],
                message: "よろしく！"
            )
        )
    }
    .modelContainer(for: Participant.self, inMemory: true)
}
