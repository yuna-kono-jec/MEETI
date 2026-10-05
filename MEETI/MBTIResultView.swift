//
//  MBTIResultView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI
import SwiftData

struct MBTIResultView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var participants: [Participant]
    @State private var savedParticipant: Participant?
    @State private var showBusinessCard = false
    
    var nickname: String
    var interests: [String]
    var message: String
    var mbti: String
    
    private func saveParticipant() {
        
        let nextNumber = (participants.map { $0.number }.max() ?? 0) + 1
        
        let participant = Participant(

            number: nextNumber,
            nickname: nickname,
            mbti: mbti,
            interests: interests,
            message: message
        )

        modelContext.insert(participant)
        savedParticipant = participant
    }
    
    var body: some View {
        VStack {
            Text("診断結果")

            Text(mbti)
            
            Button("名刺を作る") {
                saveParticipant()
                showBusinessCard = true
            }
        }//VStack end
        .navigationDestination(isPresented: $showBusinessCard) {
            if let participant = savedParticipant {
                BusinessCardView(participant: participant)
            }
        }
    }
}

#Preview {
    MBTIResultView(
        nickname: "ゆな",
        interests: ["ゲーム", "犬", "旅行"],
        message: "よろしく！",
        mbti: "ENTJ"
    )
}
