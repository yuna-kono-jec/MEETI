import Foundation

// 12問の回答途中の状態を管理する。
struct MBTIDiagnosisSession {
    private(set) var answers: [String] = []

    // 今何問目かを返す
    var currentQuestionIndex: Int {
        return answers.count
    }

    // 12問すべてに回答したかを返す
    var isComplete: Bool {
        return answers.count == mbtiQuestions.count
    }

    // 現在表示する質問。完了後はnilになる。
    var currentQuestion: MBTIQuestion? {
        if isComplete {
            return nil
        }

        return mbtiQuestions[currentQuestionIndex]
    }

    // AまたはBの回答を追加する
    // 追加できたらtrueを返す
    mutating func selectAnswer(_ answer: String) -> Bool {
        let uppercasedAnswer = answer.uppercased()

        if uppercasedAnswer != "A" && uppercasedAnswer != "B" {
            return false
        }

        if isComplete {
            return false
        }

        answers.append(uppercasedAnswer)
        return true
    }

    // 1つ前の回答に戻る
    mutating func goBack() {
        if !answers.isEmpty {
            answers.removeLast()
        }
    }

    // 12問完了後に診断結果を返す
    func calculateResult() -> String? {
        return MBTICalculator.calculate(answers: answers)
    }
}
