//
//  MatchingView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct MatchingView: View {
    var participant: Participant
    var body: some View {
        VStack {
            Text("あなたにぴったりの人を探しています…")

            ProgressView()

            NavigationLink("マッチング結果を見る") {
                // 今マッチングしている本人のデータを結果画面に渡す
                MatchResultView(participant: participant)
            }
        }//VStack end
    }
}

#Preview {
    MatchingView(
        participant: Participant(
            number: 1,
            nickname: "ゆな",
            mbti: "ENTJ",
            interests: ["ゲーム", "犬", "旅行"],
            message: "よろしく！"
        )
    )
}
