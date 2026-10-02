import Foundation

// 相性計算の結果をまとめる
struct CompatibilityResult {
    var totalScore: Int
    var mbtiScore: Int
    var interestScore: Int
    var sharedInterests: [String]
}

struct CompatibilityCalculator {

    // 2人の相性を計算する
    static func calculate(
        first: Participant,
        second: Participant
    ) -> CompatibilityResult {

        var mbtiScore = 0

        // MBTIを1文字ずつに分ける
        let firstMBTI = Array(first.mbti)
        let secondMBTI = Array(second.mbti)

        // MBTIが両方4文字なら計算する
        if firstMBTI.count == 4 && secondMBTI.count == 4 {

            // 1文字目 E / I
            if firstMBTI[0] == secondMBTI[0] {
                mbtiScore += 18
            }

            // 2文字目 S / N
            if firstMBTI[1] == secondMBTI[1] {
                mbtiScore += 18
            }

            // 3文字目 T / F
            if firstMBTI[2] == secondMBTI[2] {
                mbtiScore += 17
            }

            // 4文字目 J / P
            if firstMBTI[3] == secondMBTI[3] {
                mbtiScore += 17
            }
        }

        // 共通する「好きなこと」を入れる配列
        var sharedInterests: [String] = []

        // 1人目の好きなことを1つずつ確認
        for interest in first.interests {

            // 2人目も同じものを選んでいたら追加
            if second.interests.contains(interest) {
                sharedInterests.append(interest)
            }
        }

        // 共通する好きなこと1個につき10点
        var interestScore = sharedInterests.count * 10

        // 最大30点
        if interestScore > 30 {
            interestScore = 30
        }

        // MBTI + 好きなこと
        let totalScore = mbtiScore + interestScore

        return CompatibilityResult(
            totalScore: totalScore,
            mbtiScore: mbtiScore,
            interestScore: interestScore,
            sharedInterests: sharedInterests
        )
    }
}
