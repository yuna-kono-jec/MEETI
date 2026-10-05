import Foundation

// 12問の回答途中の状態を管理します。
struct MBTIDiagnosisSession {
    private(set) var answers: [String] = []

    // 今、何問目かを返します。
    var currentQuestionIndex: Int {
        return answers.count
    }

    // 12問すべてに回答したかを返します。
    var isComplete: Bool {
        return answers.count == mbtiQuestions.count
    }

    // 現在表示する質問です。完了後はnilになります。
    var currentQuestion: MBTIQuestion? {
        if isComplete {
            return nil
        }

        return mbtiQuestions[currentQuestionIndex]
    }

    // AまたはBの回答を追加します。
    // 追加できた場合はtrueを返します。
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

    // 1つ前の回答に戻ります。
    mutating func goBack() {
        if !answers.isEmpty {
            answers.removeLast()
        }
    }

    // 12問完了後に診断結果を返します。
    func calculateResult() -> String? {
        return MBTICalculator.calculate(answers: answers)
    }
}
