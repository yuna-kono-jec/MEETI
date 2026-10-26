//
//  ContentView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        StartView()
    }
}

#Preview {
    ContentView()
        // Preview内の画面遷移でも共通Storeを渡し、実保存先は使用しません。
        .environmentObject(try! ParticipantStore(inMemory: true))
}
