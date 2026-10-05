//
//  MatchingView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI
import SwiftData

struct MatchingView: View {
    @Environment(\.modelContext) private var modelContext

    // 新しく保存された参加者が先頭になる
    @Query(sort: \Participant.createdAt, order: .reverse)
    private var participants: [Participant]

    @State private var result: BestMatchResult?

    var body: some View {
        VStack {
            Text("あなたにぴったりの人を探しています…")

            ProgressView()

            NavigationLink("マッチング結果を見る") {
                MatchResultView(result: result)
            }
        }//VStack end
        .onAppear {
            calculateBestMatch()
        }
    }

    // 最新の参加者を自分としてBEST MATCHを計算する
    private func calculateBestMatch() {
        guard let currentParticipant = participants.first else {
            result = nil
            return
        }

        result = BestMatchCalculator.findBestMatches(
            participant: currentParticipant,
            modelContext: modelContext
        )
    }
}

#Preview {
    MatchingView()
}
