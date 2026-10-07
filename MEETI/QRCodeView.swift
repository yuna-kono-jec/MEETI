//
//  QRCodeView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct QRCodeView: View {
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
