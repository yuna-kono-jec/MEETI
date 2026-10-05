import SwiftUI

struct PartnerCardView: View {
    var participant: Participant?

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

                NavigationLink("自分の名刺を持ち帰る") {
                    QRCodeView()
                }
            } else {
                Text("参加者情報がありません")
            }
        }
    }
}

#Preview {
    PartnerCardView(participant: nil)
}
