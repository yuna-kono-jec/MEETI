//
//  MatchResultView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct MatchResultView: View {
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
    MatchResultView()
}
