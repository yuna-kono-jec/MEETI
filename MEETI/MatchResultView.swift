//
//  MatchResultView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct MatchResultView: View {
    var result: BestMatchResult?

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

                            NavigationLink("この人の名刺を見る") {
                                PartnerCardView(participant: match.participant)
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
    MatchResultView(result: nil)
}
