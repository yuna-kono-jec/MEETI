//
//  QRCodeView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct QRCodeView: View {
    // StartViewが提供する終了操作を受け取り、本人や相手のデータは変更しません。
    @Environment(\.finishMEETIExperience) private var finishExperience

    // QRコードに使う自分の参加者データを受け取る
    var participant: Participant
    
    var body: some View {
        // Web名刺URLの接続前なので、読み取り可能なQRと誤認しない案内を表示します。
        MEETIScreen(eyebrow: "08 / TAKE AWAY", title: "名刺を持ち帰ろう", subtitle: "今日の出会いを、これからも。") {
            VStack(spacing: 24) {
                Image(systemName: "qrcode").font(.system(size: 130, weight: .light))
                    .foregroundStyle(MEETIStyle.green.opacity(0.35)).accessibilityHidden(true)
                Text("Web名刺は準備中です").font(.headline)
                Text("QRコードはWeb名刺との接続後に表示されます。")
                    .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                Text("このアイコンは読み取り用QRコードではありません").font(.caption).foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity).meetiCard()
            MEETIParticipantCard(participant: participant)
            // QR・名刺の表示を維持したまま、その下に次の参加者へ渡すための案内を追加します。
            VStack(spacing: 12) {
                Text("名刺を保存したら、次の人へ")
                    .font(.caption).foregroundStyle(.secondary)
                Button {
                    // 1画面だけ戻るdismissではなく、ルートでNavigationStack全体を再生成します。
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
                // ルートに接続されていない単体Previewでは、無効な終了操作を防ぎます。
                .disabled(finishExperience == nil)
            }.frame(maxWidth: .infinity)
        }
    }
}

#Preview {
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
