//
//  QRCodeView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct QRCodeView: View {
    @Environment(\.finishMEETIExperience)
    private var finishExperience

    var participant: Participant

    var body: some View {
        MEETIScreen(
            eyebrow: "08 / TAKE AWAY",
            title: "名刺を持ち帰ろう",
            subtitle: "今日の出会いを、これからも。"
        ) {
            VStack(spacing: 24) {
                if let url = CardURLBuilder.makeURL(
                    from: participant
                ) {
                    if let qrImage = QRCodeGenerator.generate(
                        from: url.absoluteString
                    ) {
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
                } else {
                    Text("URLを作成できませんでした。")
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
                .disabled(finishExperience == nil)
            }
            .frame(maxWidth: .infinity)
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
}
