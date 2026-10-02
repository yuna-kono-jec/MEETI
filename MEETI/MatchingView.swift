//
//  MatchingView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct MatchingView: View {
    var body: some View {
        VStack {
            Text("あなたにぴったりの人を探しています…")

            ProgressView()

            NavigationLink("マッチング結果を見る") {
                MatchResultView()
            }
        }//VStack end
    }
}

#Preview {
    MatchingView()
}
