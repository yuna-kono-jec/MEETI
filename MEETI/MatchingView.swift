import SwiftUI
import SwiftData

struct MatchingView: View {
    @Environment(\.modelContext) private var modelContext

    var participant: Participant

    @State private var result: BestMatchResult?

    var body: some View {
        VStack {
            Text("あなたにぴったりの人を探しています…")

            ProgressView()

            NavigationLink("マッチング結果を見る") {
                MatchResultView(result: result)
            }
        }
        .onAppear {
            calculateBestMatch()
        }
    }

    private func calculateBestMatch() {
        result = BestMatchCalculator.findBestMatches(
            participant: participant,
            modelContext: modelContext
        )
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
