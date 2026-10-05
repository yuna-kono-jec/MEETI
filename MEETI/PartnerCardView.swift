//
//  PartnerCardView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct PartnerCardView: View {
    var body: some View {
        VStack {
            Text("MATCH CARD")

            Text("No.012")

            Text("たえちゃん")

            Text("INFP")

            Text("趣味・好きなもの")
            Text("犬・カフェ・旅行")

            Text("ひとこと")
            Text("よろしくお願いします！")

            Text("文化祭のどこかにいるかも！")
            
            NavigationLink("自分の名刺を持ち帰る") {
                QRCodeView()
            }
        }//VStack end
    }
}

#Preview {
    PartnerCardView()
}
