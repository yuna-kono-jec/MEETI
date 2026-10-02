import Foundation

struct MBTICalculator {

    static func calculate(answers: [String]) -> String {

        var eScore = 0
        var iScore = 0
        var sScore = 0
        var nScore = 0
        var tScore = 0
        var fScore = 0
        var jScore = 0
        var pScore = 0

        // 12問の回答を1問ずつ確認
        for i in 0..<answers.count {

            let answer = answers[i]
            let question = mbtiQuestions[i]

            var selectedType = ""

            if answer == "A" {
                selectedType = question.optionAType
            } else if answer == "B" {
                selectedType = question.optionBType
            }

            // 選ばれたタイプに1点追加
            if selectedType == "E" {
                eScore += 1
            } else if selectedType == "I" {
                iScore += 1
            } else if selectedType == "S" {
                sScore += 1
            } else if selectedType == "N" {
                nScore += 1
            } else if selectedType == "T" {
                tScore += 1
            } else if selectedType == "F" {
                fScore += 1
            } else if selectedType == "J" {
                jScore += 1
            } else if selectedType == "P" {
                pScore += 1
            }
        }

        // 最終的なMBTIを作る
        var result = ""

        if eScore > iScore {
            result += "E"
        } else {
            result += "I"
        }

        if sScore > nScore {
            result += "S"
        } else {
            result += "N"
        }

        if tScore > fScore {
            result += "T"
        } else {
            result += "F"
        }

        if jScore > pScore {
            result += "J"
        } else {
            result += "P"
        }

        return result
    }
}
