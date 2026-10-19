import Foundation

// 好きなことを最大3つまで選ぶ処理
struct InterestSelection {
    private(set) var selectedInterests: [String] = []

    // 選択または選択解除をする
    // 変更できたらtrueを返す
    mutating func toggle(_ interest: String) -> Bool {
        if !interestOptions.contains(interest) {
            return false
        }

        // 選択済みなら解除する
        if let index = selectedInterests.firstIndex(of: interest) {
            selectedInterests.remove(at: index)
            return true
        }

        // すでに3つ選ばれていたら追加しない
        if selectedInterests.count >= 3 {
            return false
        }

        selectedInterests.append(interest)
        return true
    }

    // 指定した項目が選ばれているか確認する
    func isSelected(_ interest: String) -> Bool {
        return selectedInterests.contains(interest)
    }
}
