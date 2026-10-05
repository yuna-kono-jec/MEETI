//
//  QRCodeView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct QRCodeView: View {
    // QRコードに使う自分の参加者データを受け取る
    var participant: Participant
    
    var body: some View {
        VStack {
            Text("あなたの名刺を持ち帰る")

            Image(systemName: "qrcode")
                .font(.system(size: 150))

            Text("QRコードを読み取ってね！")
        }//VStack end
    }
}

#Preview {
    QRCodeView(
        participant: Participant(
            number: 1,
            nickname: "ゆな",
            mbti: "ENTJ",
            interests: ["ゲーム", "犬", "旅行"],
            message: "よろしく！"
        )
    )
}
