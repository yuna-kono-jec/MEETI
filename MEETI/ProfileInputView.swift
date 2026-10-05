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
    
    var body: some View {
        
        VStack(alignment: .leading) {
            TextField("ニックネームを入力", text: $nickname)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Text("好きなことを3つ選んでね")
                .padding(.horizontal)
            
            Text("\(interests.count) / 3 選択中")
                .padding(.horizontal)
            
            ForEach(interestOptions, id: \.self) { interest in
                Button(interests.contains(interest) ? "✓ \(interest)" : interest) {
                    if interests.contains(interest) {
                        interests.removeAll { $0 == interest }
                    } else if interests.count < 3 {
                        interests.append(interest)
                    }
                }
                .padding(.horizontal)
            }
            
            Text("ひとこと")
                .padding(.horizontal)
            TextEditor(text: $message)
                .frame(height: 100)
                .border(.gray)
                .padding()
            
            NavigationLink("次へ") {
                MBTIQuestionView(
                    nickname: nickname,
                    interests: interests,
                    message: message
                )
            }
            .padding()
            .disabled(interests.count != 3)
            
        }//VStack end
    }
}

#Preview {
    ProfileInputView()
}
