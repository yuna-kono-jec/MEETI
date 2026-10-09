//
//  MBTIQuestionView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct MBTIQuestionView: View {
    let participant: Participant
    
    var body: some View {
        VStack(spacing: 16) {
            Text("MBTI診断")
            
            Text("ここに質問が入ります")
            
            Text("現在は接続確認用にENFJを使います")
                .font(.caption)
            
            NavigationLink {
                MBTIResultView(participant: participant)
            } label: {
                Text("診断結果へ")
            }
        }
        .onAppear {
            // 診断機能が完成したら、実際の結果に置き換える
            participant.mbti = "ENFJ"
        }
    }
}

#Preview {
    NavigationStack {
        MBTIQuestionView(
            participant: Participant(
                number: 37,
                nickname: "TEST",
                mbti: "",
                interests: ["音楽", "旅行"],
                message: "よろしくお願いします！"
                
            )
        )
        
    }
}
