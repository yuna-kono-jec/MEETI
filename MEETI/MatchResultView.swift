//
//  MatchResultView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct MatchResultView: View {
    // この画面で使う参加者データを受け取る
    var participant: Participant

    var body: some View {
        VStack {
            Text("BEST MATCH")

            Text("相性 92%")

            Text("No.012")

            Text("たえちゃん")

            Text("INFP")

            Text("共通点")
            Text("犬・カフェ")

            NavigationLink("この人の名刺を見る") {
                PartnerCardView()
            }
        }//VStack end
    }
}

#Preview {
    // プレビュー画面で確認するための仮の参加者データ
    MatchResultView(
        participant: Participant(
            number: 1,
            nickname: "ゆな",
            mbti: "ENTJ",
            interests: ["ゲーム", "犬", "旅行"],
            message: "よろしく！"
        )
    )
}
