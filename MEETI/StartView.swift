//
//  StartView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        
        NavigationStack {
            NavigationLink("MEETIをはじめる") {
                ProfileInputView()
            }
        }//NavigationStack end
        
    }
}
#Preview {
    StartView()
}
