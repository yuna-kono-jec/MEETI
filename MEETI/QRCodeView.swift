//
//  QRCodeView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct QRCodeView: View {
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
    QRCodeView()
}
