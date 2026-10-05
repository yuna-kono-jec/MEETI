import Foundation

// 好きなことを最大3つまで選ぶ処理です。
struct InterestSelection {
    private(set) var selectedInterests: [String] = []

    // 選択または選択解除をします。
    // 正常に変更できた場合はtrueを返します。
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

    // 指定した項目が選ばれているか確認します。
    func isSelected(_ interest: String) -> Bool {
        return selectedInterests.contains(interest)
    }
}
