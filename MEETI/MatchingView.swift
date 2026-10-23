import SwiftUI

struct MatchingView: View {
    var participant: Participant

    @State private var result: BestMatchResult?
    @State private var participants: [Participant] = []
    @State private var preferredGender = "どちらでも"
    @State private var preferredAgeGroup = "指定しない"
    @State private var isLoading = true
    @State private var loadError = ""
    // 条件変更では取得済みプロフィールを再利用し、古い通信結果の上書きを防ぎます。
    @State private var hasLoadedParticipants = false
    @State private var activeRequest = UUID()

    var body: some View {
        // Supabaseの参加者を読み込んでから相性を計算する
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

            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("参加者データを読み込んでいます")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .meetiCard()
            } else if !loadError.isEmpty {
                VStack(spacing: 16) {
                    Text(loadError)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("もう一度読み込む") {
                        Task {
                            await loadParticipants()
                        }
                    }
                    .buttonStyle(MEETIButtonStyle())
                }
                .meetiCard()
            } else {
                VStack(spacing: 28) {
                    // 写真がなくてもMBTI画像で表示できる
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
        }
        // 条件が変わったら前の処理を止めて、相性を計算し直す
        .task(id: [preferredGender, preferredAgeGroup]) {
            await loadParticipants()
        }
        .onDisappear {
            // 再びこの画面へ戻ったときは、他端末で増えた参加者も従来どおり再取得します。
            hasLoadedParticipants = false
        }
    }

    @MainActor
    private func loadParticipants() async {
        let request = UUID()
        activeRequest = request
        isLoading = true
        loadError = ""
        defer {
            // 中断した古い処理が、新しい読み込みの表示を解除しないようにします。
            if activeRequest == request { isLoading = false }
        }
        do {
            if !hasLoadedParticipants {
                let fetched = try await ParticipantSyncService.fetchParticipants()
                try Task.checkCancellation()
                guard activeRequest == request else { return }
                participants = fetched
                hasLoadedParticipants = true
            }
            // 全員のプロフィールから、従来の計算・フィルタ・同率対応で結果を求めます。
            let nextResult = BestMatchCalculator.findBestMatches(
                participant: participant, candidates: participants,
                preferredGender: preferredGender, preferredAgeGroup: preferredAgeGroup
            )
            // 写真は結果画面で取得するので、ここでは待たない
            try Task.checkCancellation()
            guard activeRequest == request else { return }
            result = nextResult
        } catch is CancellationError {
            // 条件変更・画面終了による中断は、通信エラーとして表示しません。
        } catch {
            guard activeRequest == request else { return }
            result = nil
            loadError = "共有データを読み込めませんでした。通信環境を確認してください。"
        }
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
