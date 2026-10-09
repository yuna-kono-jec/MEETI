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
    var photoData: Data?
    
    private func saveParticipant() {
        
        let nextNumber = (participants.map { $0.number }.max() ?? 0) + 1
        
        let participant = Participant(

            number: nextNumber,
            nickname: nickname,
            mbti: mbti,
            interests: interests,
            message: message,
            photoData: photoData
        )

        modelContext.insert(participant)
        savedParticipant = participant
    }
    
    var body: some View {
        // 診断結果のタイプ名で既存Assetsの画像を表示します。
        MEETIScreen(eyebrow: "03 / RESULT", title: "あなたのタイプ", subtitle: "あなたらしさを、名刺に添えて。") {
            VStack(spacing: 24) {
                Text(mbti).font(.system(size: 40, weight: .medium, design: .rounded)).tracking(6).foregroundStyle(MEETIStyle.green)
                MEETITypeImage(type: mbti)
                Text("好きなことも、あなたの個性のひとつ。\n次は自己紹介カードを作りましょう。")
                    .multilineTextAlignment(.center).font(.subheadline).lineSpacing(6)
            }.frame(maxWidth: .infinity).meetiCard()
            Button("名刺を作る") {
                saveParticipant()
                showBusinessCard = true
            }.buttonStyle(MEETIButtonStyle())
        }
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
        mbti: "ENTJ",
        photoData: nil
    )
}
