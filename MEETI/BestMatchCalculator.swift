import Foundation

// BEST MATCHの結果
struct BestMatchResult {
    var matches: [Participant]
    var score: Int
}

struct BestMatchCalculator {

    // 一番相性の良い参加者を探す
    static func findBestMatches(
        participant: Participant,
        candidates: [Participant]
    ) -> BestMatchResult? {

        // 一番相性の良い人を入れる
        var bestMatches: [Participant] = []

        // 今までで一番高い点数
        var bestScore = -1

        // 参加者を1人ずつ調べる
        for candidate in candidates {

            // 自分自身とはマッチングしない
            if candidate.number == participant.number {
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
                bestMatches = [candidate]

            // 最高点と同じだった場合
            } else if result.totalScore == bestScore {

                bestMatches.append(candidate)
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
}
