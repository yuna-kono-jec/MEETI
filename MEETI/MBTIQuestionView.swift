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
    
    var body: some View {
        VStack {
            Text("MBTI診断")
            
            Text("ここに質問が入ります")
            
            NavigationLink("診断結果へ") {
                MBTIResultView(
                    nickname: nickname,
                    interests: interests,
                    message: message,
                    mbti: "ENTJ"
                )
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
