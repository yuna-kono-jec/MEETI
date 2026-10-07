import SwiftUI

struct MatchResultView: View {
    var result: BestMatchResult?
    
    var currentParticipant: Participant

    var body: some View {
        // 同率1位の全員表示と、本人データの引き継ぎを維持します。
        MEETIScreen(eyebrow: "06 / BEST MATCH", title: "あなたのベストマッチ", subtitle: "共通点をきっかけに、話しかけてみよう。") {
            VStack(spacing: 24) {


                if let result = result {
                    // 同率1位の場合は全員表示する
                    ForEach(result.matches) { match in
                        // 同率の各相手について、本人と相手を左右に並べます。
                        VStack(spacing: 20) {
                            Text("BEST MATCH!").font(.title3.weight(.medium)).tracking(2)
                                .foregroundStyle(Color(red: 0.72, green: 0.43, blue: 0.48))
                            Text("相性 \(match.compatibility.totalScore)%").font(.largeTitle.weight(.semibold))
                                .foregroundStyle(Color(red: 0.72, green: 0.43, blue: 0.48))
                            HStack(alignment: .top, spacing: 12) {
                                matchIdentity(currentParticipant)
                                Image(systemName: "heart.fill").foregroundStyle(MEETIStyle.pink).padding(.top, 35).accessibilityHidden(true)
                                matchIdentity(match.participant)
                            }
                            Text("共通点").font(.subheadline)
                            if match.compatibility.sharedInterests.isEmpty {
                                Text("共通の好きなことはまだありません").font(.caption).foregroundStyle(.secondary)
                            } else {
                                MEETIInterestTags(interests: match.compatibility.sharedInterests)
                            }
                            Text("MBTI：\(match.compatibility.mbtiScore)点 ・ 好きなこと：\(match.compatibility.interestScore)点")
                                .font(.caption).foregroundStyle(.secondary)
                            // マッチした相手の名刺画面を開く
                            NavigationLink("この人の名刺を見る") {
                                PartnerCardView(
                                    participant: match.participant,
                                    // QRコードで使うため、現在操作している本人のデータも渡す
                                    currentParticipant: currentParticipant
                                )
                            }.buttonStyle(MEETIButtonStyle())
                        }
                        .meetiCard()
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2").font(.largeTitle)
                        Text("まだマッチングできる参加者がいません")
                        Text("参加者が増えたら、前の画面からもう一度お試しください。").font(.subheadline).foregroundStyle(.secondary)
                    }.meetiCard()
                }
            }
        }
    }
    // 小さな端末でも左右の名刺を収める、マッチング結果用の表示です。
    private func matchIdentity(_ participant: Participant) -> some View {
        VStack(spacing: 8) {
            MEETIAvatar(participant: participant, size: 90).clipShape(Circle())
            Text(String(format: "No. %03d", participant.number)).font(.caption2)
            Text(participant.nickname).font(.subheadline.weight(.medium))
            Text(participant.mbti).font(.caption).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity)
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

