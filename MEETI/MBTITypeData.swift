import Foundation

// MBTIが分かっている人が選ぶ16タイプです。
let mbtiTypes: [String] = [
    "ISTJ", "ISFJ", "INFJ", "INTJ",
    "ISTP", "ISFP", "INFP", "INTP",
    "ESTP", "ESFP", "ENFP", "ENTP",
    "ESTJ", "ESFJ", "ENFJ", "ENTJ"
]

struct MBTITypeData {

    // 入力された文字が16タイプに含まれるか確認します。
    static func isValid(_ mbti: String) -> Bool {
        let uppercasedMBTI = mbti.uppercased()
        return mbtiTypes.contains(uppercasedMBTI)
    }
}
