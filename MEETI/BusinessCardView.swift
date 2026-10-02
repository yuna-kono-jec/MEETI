//
//  BusinessCardView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct BusinessCardView: View {
    var body: some View {
        VStack {
            Text("あなたの名刺")
            
            Text("No.001")
            
            Text("ゆな")
            
            Text("ENFJ")
            
            Text("趣味・好きなもの")
            Text("カフェ・犬・プログラミング")
            
            Text("ひとこと")
            Text("よろしくお願いします！")
            
            NavigationLink("QRコードを表示") {
                QRCodeView()
            }
            
            NavigationLink("マッチングする") {
                MatchingView()
            }
        }//VStack end
    }//body end
}//BusinessCardView end

#Preview {
    BusinessCardView()
}
