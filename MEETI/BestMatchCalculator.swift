import Foundation
import SwiftData

// 1人分のBEST MATCH情報
struct BestMatch: Identifiable {
    var participant: Participant
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
        participant: Participant,
        candidates: [Participant]
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

            // 2人の相性を計算
            guard let result = CompatibilityCalculator.calculate(
                first: participant,
                second: candidate
            ) else {
                // MBTIが不正な候補は飛ばす
                continue
            }

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

    // SwiftDataに保存されている全参加者からBEST MATCHを探す
    static func findBestMatches(
        participant: Participant,
        modelContext: ModelContext
    ) -> BestMatchResult? {

        let descriptor = FetchDescriptor<Participant>()

        // 保存データを取得できなかった場合は結果なし
        guard let allParticipants = try? modelContext.fetch(descriptor) else {
            return nil
        }

        return findBestMatches(
            participant: participant,
            candidates: allParticipants
        )
    }
}
