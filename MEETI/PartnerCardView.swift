import SwiftUI

struct PartnerCardView: View {
    var participant: Participant?
    // QRコード表示まで引き継ぐ、現在操作している本人の参加者データ
    var currentParticipant: Participant
    var body: some View {
        VStack {
            Text("MATCH CARD")

            if let participant = participant {
                Text("No.\(participant.number)")
                Text(participant.nickname)
                Text(participant.mbti)

                Text("好きなこと")
                Text(participant.interests.joined(separator: "・"))

                Text("ひとこと")
                Text(participant.message)

                Text("文化祭のどこかにいるかも！")

                // 自分の名刺をQRコードで持ち帰る
                NavigationLink("自分の名刺を持ち帰る") {
                    // マッチした相手ではなく、現在操作している本人のデータをQR画面へ渡す
                    QRCodeView(participant: currentParticipant)
                }
            } else {
                Text("参加者情報がありません")
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
