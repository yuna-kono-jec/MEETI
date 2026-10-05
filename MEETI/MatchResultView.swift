import SwiftUI

struct MatchResultView: View {
    var result: BestMatchResult?
    
    var currentParticipant: Participant

    var body: some View {
        ScrollView {
            VStack {
                Text("BEST MATCH")

                if let result = result {
                    // 同率1位の場合は全員表示する
                    ForEach(result.matches) { match in
                        VStack {
                            Text("相性 \(match.compatibility.totalScore)%")
                            Text("No.\(match.participant.number)")
                            Text(match.participant.nickname)
                            Text(match.participant.mbti)
                            Text("MBTI：\(match.compatibility.mbtiScore)点")
                            Text("好きなこと：\(match.compatibility.interestScore)点")
                            Text("共通している好きなこと")

                            if match.compatibility.sharedInterests.isEmpty {
                                Text("なし")
                            } else {
                                Text(match.compatibility.sharedInterests.joined(separator: "・"))
                            }

                            // マッチした相手の名刺画面を開く
                            NavigationLink("この人の名刺を見る") {
                                PartnerCardView(
                                    participant: match.participant,
                                    // QRコードで使うため、現在操作している本人のデータも渡す
                                    currentParticipant: currentParticipant
                                )
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("まだマッチングできる参加者がいません")
                }
            }
        }
    }
}

#Preview {
    MatchResultView(
        result: nil,
        currentParticipant: Participant(
            number: 1,
            nickname: "ゆな",
            mbti: "ENTJ",
            interests: ["ゲーム", "犬", "旅行"],
            message: "よろしく！"
        )
    )
}

