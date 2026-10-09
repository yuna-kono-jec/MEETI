//
//  ProfileInputView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct ProfileInputView: View {
    @State private var nickname = ""
    @State private var interests = ""
    @State private var message = ""
    
    private func makeParticipant() -> Participant {
        let interestsList = interests
            .replacingOccurrences(of: "、", with: ",")
            .replacingOccurrences(of: "，", with: ",")
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        return Participant(
            number: 37,
            nickname: nickname.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            mbti: "",
            interests: interestsList,
            message: message
        )
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            TextField("ニックネームを入力", text: $nickname)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            TextField("趣味・好きなものを入力", text: $interests)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Text("ひとこと")
                .padding(.horizontal)
            TextEditor(text: $message)
                .frame(height: 100)
                .border(.gray)
                .padding()
            
            NavigationLink {
                MBTIQuestionView(participant: makeParticipant())
            } label: {
                Text("次へ")
            }
            .disabled(
                nickname.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            )
            .padding()
                
            
        }//VStack end
    }
}

#Preview {
    NavigationStack {
        ProfileInputView()
    }
}
