//
//  MEETIApp.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI

@main
struct MEETIApp: App {
    // 画面履歴のリセットより外に保存窓口を保持し、体験終了でデータを失わないようにします。
    @StateObject private var participantStore: ParticipantStore

    init() {
        do {
            // StateObjectの遅延生成にthrowを渡さず、保存先の初期化エラーをここで扱います。
            let store = try ParticipantStore()
            _participantStore = StateObject(wrappedValue: store)
        } catch {
            // 読み込みに失敗したとき、既存DBの削除や空DBへの切り替えは行いません。
            fatalError("Could not create ParticipantStore: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // SceneではなくViewへ注入し、iOS 16の環境オブジェクトAPIを使用します。
                .environmentObject(participantStore)
        }
    }
}
