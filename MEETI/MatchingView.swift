import SwiftUI
import SwiftData

struct MatchingView: View {
    @Environment(\.modelContext) private var modelContext

    var participant: Participant

    @State private var result: BestMatchResult?
    @State private var preferredGender = "どちらでも"
    @State private var preferredAgeGroup = "指定しない"

    var body: some View {
        // 計算の実行タイミングを維持し、計算完了後は準備完了の表示にします。
        MEETIScreen(eyebrow: "05 / MATCHING", title: "出会いを見つけよう", subtitle: "MBTIと好きなことから、相性のいい人を探します。") {
            VStack(alignment: .leading, spacing: 16) {
                Text("マッチング相手の希望").font(.headline)

                Picker("性別", selection: $preferredGender) {
                    ForEach(matchingGenderOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                Picker("年代", selection: $preferredAgeGroup) {
                    ForEach(matchingAgeGroupOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
            }
            .meetiCard()

            VStack(spacing: 28) {
                // 写真データがなくても既存タイプ画像で出会いのペアを表現します。
                HStack(spacing: 16) {
                    MEETIAvatar(participant: participant, size: 110).clipShape(Circle())
                    Image(systemName: "heart").foregroundStyle(MEETIStyle.green.opacity(0.4))
                    Image(systemName: "person.crop.circle").font(.system(size: 85, weight: .ultraLight)).foregroundStyle(MEETIStyle.green)
                }.accessibilityHidden(true)
                Text("出会いの準備ができました").font(.headline)
                VStack(alignment: .leading, spacing: 16) {
                    Label("参加者データを比較", systemImage: "checkmark.circle.fill")
                    Label("MBTIと好きなことから相性を計算", systemImage: "checkmark.circle.fill")
                    Label("結果を見て、共通点を見つけよう", systemImage: "heart")
                }.font(.caption).foregroundStyle(MEETIStyle.green)
            }.frame(maxWidth: .infinity).meetiCard()
            NavigationLink("マッチング結果を見る") {
                MatchResultView(result: result, currentParticipant: participant)
            }.buttonStyle(MEETIButtonStyle())
        }
        .onAppear {
            calculateBestMatch()
        }
        .onChange(of: preferredGender) {
            calculateBestMatch()
        }
        .onChange(of: preferredAgeGroup) {
            calculateBestMatch()
        }
    }

    private func calculateBestMatch() {
        result = BestMatchCalculator.findBestMatches(
            participant: participant,
            modelContext: modelContext,
            preferredGender: preferredGender,
            preferredAgeGroup: preferredAgeGroup
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
            message: "よろしく！",
            gender: "女性",
            ageGroup: "20〜29歳"
        )
    )
}
