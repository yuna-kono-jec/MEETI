import SwiftUI

struct PartnerCardView: View {
    var participant: Participant?
    // QRコード表示まで引き継ぐ、現在操作している本人の参加者データ
    var currentParticipant: Participant
    var body: some View {
        // 相手の名刺を表示し、QR画面には従来どおり本人を渡します。
        MEETIScreen(eyebrow: "07 / MATCH CARD", title: "気になる人の名刺", subtitle: "文化祭のどこかにいるかも！") {
            if let participant = participant {
                MEETIParticipantCard(participant: participant)
                NavigationLink { QRCodeView(participant: currentParticipant) } label: {
                    Label("自分の名刺を持ち帰る", systemImage: "qrcode")
                }.buttonStyle(MEETIButtonStyle())
            } else {
                Text("参加者情報がありません").meetiCard()
            }
        }
    }
}

#Preview {
    PartnerCardView(
        participant: nil,
        // Previewで使う、現在操作している本人の仮データ
        currentParticipant: Participant(
            number: 1,
            nickname: "ゆな",
            mbti: "ENTJ",
            interests: ["ゲーム", "犬", "旅行"],
            message: "よろしく！"
        )
    )
}
