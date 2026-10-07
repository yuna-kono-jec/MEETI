//
//  MBTIQuestionView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct MBTIQuestionView: View {
    var nickname: String
    var interests: [String]
    var message: String

    @State private var selectedMethod = "12問で診断"
    @State private var diagnosis = MBTIDiagnosisSession()
    @State private var selectedMBTI = "ENFJ"
    @State private var resultMBTI = ""
    @State private var showResult = false

    var body: some View {
        MEETIScreen(eyebrow: "02 / YOUR TYPE", title: "MBTIを決めよう", subtitle: "直感で答えて、あなたらしさを見つけよう。") {
            VStack(spacing: 20) {

                // 診断するか、分かっているタイプを選ぶか切り替える
                Picker("MBTIの決め方", selection: $selectedMethod) {
                    Text("12問で診断")
                        .tag("12問で診断")
                    Text("直接選ぶ")
                        .tag("直接選ぶ")
                }
                .pickerStyle(.segmented)

                if selectedMethod == "12問で診断" {
                    diagnosisView
                } else {
                    directSelectionView
                }
            }
            .padding()
        }
        .navigationDestination(isPresented: $showResult) {
            MBTIResultView(
                nickname: nickname,
                interests: interests,
                message: message,
                mbti: resultMBTI
            )
        }
    }

    // 12問診断を共通の配色で表示し、既存の回答処理を呼び出します。
    private var diagnosisView: some View {
        VStack(spacing: 16) {
            if let question = diagnosis.currentQuestion {
                Text("\(diagnosis.currentQuestionIndex + 1) / \(mbtiQuestions.count) 問")

                // 回答状態には触れず、進み具合をバーで表示します。
                ProgressView(value: Double(diagnosis.currentQuestionIndex), total: Double(mbtiQuestions.count)).tint(MEETIStyle.green)

                Text(question.text)
                    .font(.title3.weight(.medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 20)

                Button("A. \(question.optionA)") {
                    answerQuestion("A")
                }
                .buttonStyle(MEETIButtonStyle())

                Button("B. \(question.optionB)") {
                    answerQuestion("B")
                }
                .buttonStyle(MEETIButtonStyle())

                if diagnosis.currentQuestionIndex > 0 {
                    Button("1問戻る") {
                        diagnosis.goBack()
                    }
                }
            }
        }
    }

    // 16タイプから直接選ぶ部分
    private var directSelectionView: some View {
        VStack(spacing: 16) {
            Text("自分のMBTIを選んでください")

            MBTITypePickerView(selectedMBTI: $selectedMBTI)

            Button("このタイプで決定") {
                resultMBTI = selectedMBTI
                showResult = true
            }
            .buttonStyle(MEETIButtonStyle())
        }
    }

    // 回答を保存し、12問終わったら結果画面へ進む
    private func answerQuestion(_ answer: String) {
        let added = diagnosis.selectAnswer(answer)

        if added && diagnosis.isComplete {
            if let result = diagnosis.calculateResult() {
                resultMBTI = result
                showResult = true
            }
        }
    }
}

#Preview {
    MBTIQuestionView(
        nickname: "ゆな",
        interests: ["ゲーム", "犬", "旅行"],
        message: "よろしく！"
    )
}
