//
//  QRCodeView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct QRCodeView: View {
    
    let participant : Participant
    
    var body: some View {
        VStack(spacing: 20) {
            Text("あなたの名刺を持ち帰る")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            
            if let url = CardURLBuilder.makeURL(from: participant) {
                
                if let qrImage = QRCodeGenerator.generate(
                    from: url.absoluteString
                ) {
                    
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .padding(20)
                        .background(Color.white)
                    
                } else {
                    Text("QRコードを作成できませんでした。")
                }
            } else {
                Text("URLを作成できませんでした。")
            }
            
            Text(String(format: "No.%03d", participant.number))
            Text(participant.nickname)
                .font(.title2)
                .bold()
            
            Text(participant.mbti)
            
        }//VStack end
        .padding()
        
        
    }
}


#Preview {
    QRCodeView(
        participant: Participant(
            number: 37,
            nickname: "TEST",
            mbti: "INFP",
            interests: ["ゲーム", "映画", "旅行"],
            message: "話しかけてください！😊"
        )
    )
}
