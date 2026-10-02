//
//  MBTIResultView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct MBTIResultView: View {
    var body: some View {
        VStack {
            Text("診断結果")

            Text("ENFJ")
            
            NavigationLink("名刺を作る") {
                BusinessCardView()
            }
        }//VStack end
    }
}

#Preview {
    MBTIResultView()
}
