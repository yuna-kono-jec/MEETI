//
//  ProfileInputView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI
import SwiftData

struct ProfileInputView: View {
    @State private var nickname = ""
    @State private var interests: [String] = []
    @State private var message = ""
    
    
    let interestOptions = [
        "音楽",
        "旅行",
        "カフェ",
        "映画",
        "アニメ",
        "スポーツ",
        "読書",
        "ゲーム",
        "ショッピング",
        "アウトドア",
        "グルメ",
        "犬",
        "猫",
        "アート"
    ]
    
    // 選択上限と次へ進める条件は既存のまま、入力欄をカード化します。
    var body: some View {
        MEETIScreen(eyebrow: "01 / PROFILE", title: "プロフィールを入力しよう", subtitle: "好きなことが、出会いのきっかけに。") {
            // 写真選択の未接続状態をカメラボタンに見せず、プロフィールの装飾を表示します。
            Image(systemName: "person.crop.circle").font(.system(size: 75, weight: .ultraLight))
                .foregroundStyle(MEETIStyle.green).frame(maxWidth: .infinity).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 14) {
                Text("ニックネーム").font(.headline)
                TextField("ニックネームを入力", text: $nickname).padding(14)
                    .background(MEETIStyle.ivory, in: RoundedRectangle(cornerRadius: 12))
            }.meetiCard()
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("好きなこと").font(.headline)
                    Spacer()
                    Text("\(interests.count) / 3").font(.subheadline.monospacedDigit()).foregroundStyle(MEETIStyle.green)
                }
                Text("3つ選んでね").font(.caption).foregroundStyle(.secondary)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                    ForEach(interestOptions, id: \.self) { interest in
                        Button {
                            if interests.contains(interest) {
                                interests.removeAll { $0 == interest }
                            } else if interests.count < 3 {
                                interests.append(interest)
                            }
                        } label: {
                            Text(interests.contains(interest) ? "✓ \(interest)" : interest)
                                .font(.caption).padding(.vertical, 9).frame(maxWidth: .infinity)
                                .background(interests.contains(interest) ? MEETIStyle.green : MEETIStyle.beige.opacity(0.45), in: Capsule())
                                .foregroundStyle(interests.contains(interest) ? .white : MEETIStyle.ink)
                        }.buttonStyle(.plain)
                        .accessibilityAddTraits(interests.contains(interest) ? .isSelected : [])
                    }
                }
            }.meetiCard()
            VStack(alignment: .leading, spacing: 12) {
                Text("ひとこと").font(.headline)
                Text("話してみたいことを書いてみよう").font(.caption).foregroundStyle(.secondary)
                TextEditor(text: $message).scrollContentBackground(.hidden).frame(height: 100)
                    .padding(8).background(MEETIStyle.ivory, in: RoundedRectangle(cornerRadius: 12))
                    .accessibilityLabel("ひとこと")
            }.meetiCard()
            NavigationLink {
                MBTIQuestionView(nickname: nickname, interests: interests, message: message)
            } label: { Label("MBTIを決める", systemImage: "arrow.right") }
                .buttonStyle(MEETIButtonStyle()).disabled(interests.count != 3)
        }.scrollDismissesKeyboard(.interactively)
    }
}

#Preview {
    ProfileInputView()
}
