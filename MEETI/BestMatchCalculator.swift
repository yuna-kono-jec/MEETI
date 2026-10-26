import Foundation

// 1人分のBEST MATCH情報
struct BestMatch: Identifiable {
    // 保存方式によらないプロフィールで、従来と同じ順位計算を行います。
    var participant: ParticipantProfile
    var compatibility: CompatibilityResult

    // 画面で参加者を区別するために受付番号を使う
    var id: Int {
        return participant.number
    }
}

// BEST MATCHの結果
struct BestMatchResult {
    var matches: [BestMatch]
    var score: Int
}

struct BestMatchCalculator {

    // 一番相性の良い参加者を探す
    static func findBestMatches(
        participant: ParticipantProfile,
        candidates: [ParticipantProfile],
        preferredGender: String = "どちらでも",
        preferredAgeGroup: String = "指定しない"
    ) -> BestMatchResult? {

        // 一番相性の良い人を入れる
        var bestMatches: [BestMatch] = []

        // 今までで一番高い点数
        var bestScore = -1

        // 参加者を1人ずつ調べる
        for candidate in candidates {

            // 自分自身とはマッチングしない
            if candidate.number == participant.number {
                continue
            }

            // 希望した性別と違う参加者は候補から外す
            if preferredGender != "どちらでも" && candidate.gender != preferredGender {
                continue
            }

            // 希望した年代と違う参加者は候補から外す
            if preferredAgeGroup != "指定しない" && candidate.ageGroup != preferredAgeGroup {
                continue
            }

            // 2人の相性を計算
            let result = CompatibilityCalculator.calculate(
                first: participant,
                second: candidate
            )

            // 今までの最高点より高かった場合
            if result.totalScore > bestScore {

                bestScore = result.totalScore
                bestMatches = [
                    BestMatch(
                        participant: candidate,
                        compatibility: result
                    )
                ]

            // 最高点と同じだった場合
            } else if result.totalScore == bestScore {

                bestMatches.append(
                    BestMatch(
                        participant: candidate,
                        compatibility: result
                    )
                )
            }
        }

        // 自分以外に参加者がいなかった場合
        if bestMatches.isEmpty {
            return nil
        }

        return BestMatchResult(
            matches: bestMatches,
            score: bestScore
        )
    }

    // OSごとの保存方式を共通Storeで吸収し、全参加者からの計算を維持します。
    @MainActor
    static func findBestMatches(
        participant: ParticipantProfile,
        participantStore: ParticipantStore,
        preferredGender: String = "どちらでも",
        preferredAgeGroup: String = "指定しない"
    ) -> BestMatchResult? {

        // 保存データを取得できなかった場合は結果なし
        guard let allParticipants = try? participantStore.fetchAll() else {
            return nil
        }

        return findBestMatches(
            participant: participant,
            candidates: allParticipants,
            preferredGender: preferredGender,
            preferredAgeGroup: preferredAgeGroup
        )
    }
}
