//
//  MBTIQuestionView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct MBTIQuestionView: View {
    var body: some View {
        VStack {
            Text("MBTI診断")
            
            Text("ここに質問が入ります")
            
            NavigationLink("診断結果へ") {
                MBTIResultView()
            }
        }    }
}

#Preview {
    MBTIQuestionView()
}
