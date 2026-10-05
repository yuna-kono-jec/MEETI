//
//  BusinessCardView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct BusinessCardView: View {
    var participant: Participant
    
    var body: some View {
        VStack {
            Text("あなたの名刺")
            
            Text("No.\(String(format: "%03d", participant.number))")
            
            Text(participant.nickname)
            
            Text(participant.mbti)
            
            Text("趣味・好きなもの")
            Text(participant.interests.joined(separator: "・"))
            
            Text("ひとこと")
            Text(participant.message)
            
            
            NavigationLink("マッチングする") {
                MatchingView(participant: participant)
            }
            
        }//VStack end
    }//body end
}//BusinessCardView end

#Preview {
    BusinessCardView(
        participant: Participant(
            number: 1,
            nickname: "ゆな",
            mbti: "ENTJ",
            interests: ["ゲーム", "犬", "旅行"],
            message: "よろしく！"
        )
    )
}
