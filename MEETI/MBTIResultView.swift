//
//  MBTIResultView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct MBTIResultView: View {
    let participant: Participant
    
    var body: some View {
        VStack(spacing: 16) {
            Text("診断結果")

            Text(participant.mbti)
            
            NavigationLink("名刺を作る") {
                BusinessCardView(participant: participant)
            }
        }//VStack end
    }
}

#Preview {
    NavigationStack {
        MBTIResultView(
            participant: Participant(
                number: 37,
                nickname: "TEST",
                mbti: "ENFJ",
                interests: ["音楽", "旅行"],
                message: "よろしくお願いします！"
            )
        )
    }
}
