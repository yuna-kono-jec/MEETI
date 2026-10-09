//
//  BusinessCardView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct BusinessCardView: View {
    let participant: Participant
    
    var body: some View {
        VStack (spacing: 16){
            Text("あなたの名刺")
            
            Text(String(format: "No.%03d", participant.number))
            
            Text(participant.nickname)
            
            Text(participant.mbti)
            
            Text("趣味・好きなもの")
            Text(participant.interests.joined(separator: "・"))
            
            Text("ひとこと")
            Text(participant.message)
            
            NavigationLink("QRコードを表示") {
                QRCodeView(participant: participant)
            }
            
            NavigationLink("マッチングする") {
                MatchingView()
            }
        }//VStack end
        .padding()
    }//body end
}//BusinessCardView end

#Preview {
    NavigationStack {
        BusinessCardView(
            participant: Participant(
                number: 37,
                nickname: "TEST",
                mbti: "INFP",
                interests: ["ゲーム", "映画", "旅行"],
                message: "話しかけてください！😊"
            )
        )
    }
    
}
