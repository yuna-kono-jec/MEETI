//
//  OperatorParticipantsView.swift
//  MEETI
//
//  Created by cmStudent on 2026/10/23.
//

import SwiftUI
import SwiftData
import Supabase

struct OperatorParticipantsView: View {
    private struct Card: Decodable, Identifiable {
        let id: UUID
        let number: Int
        let nickname: String
        let mbti: String
    }
    private struct DeleteResponse: Decodable { let deleted: Bool }
    private let operatorID = "b6a5494b-4545-4beb-8d83-7c92a0cf8da3"
    @Environment(\.modelContext) private var modelContext
    @State private var cards: [Card] = []
    @State private var pending: Card?
    @State private var busy = false
    @State private var errorMessage = ""
    @State private var notice = ""

    var body: some View {
        List {
            if busy { ProgressView("処理中です") }
            if !notice.isEmpty { Text(notice) }
            if cards.isEmpty && !busy { Text("表示する名刺はありません。") }
            ForEach(cards) { card in
                HStack {
                    VStack(alignment: .leading) {
                        Text("No. \(card.number)  \(card.nickname)")
                        Text(card.mbti).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(role: .destructive) { pending = card } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("\(card.nickname)の名刺を削除")
                    .disabled(busy)
                }
            }
        }
        .navigationTitle("名刺の管理")
        .toolbar {
            Button("更新") { Task { await load() } }.disabled(busy)
        }
        .task { await load() }
        .alert("名刺を完全に削除しますか？", isPresented: Binding(
            get: { pending != nil },
            set: { if !$0 { pending = nil } }
        )) {
            if let card = pending {
                Button("削除する", role: .destructive) {
                    pending = nil
                    Task { await delete(card) }
                }
            }
            Button("キャンセル", role: .cancel) { pending = nil }
        } message: {
            Text("\(pending?.nickname ?? "")の参加者情報・写真・Web写真共有情報を削除します。この操作は取り消せません。")
        }
        .alert("処理を完了できませんでした", isPresented: Binding(
            get: { !errorMessage.isEmpty },
            set: { if !$0 { errorMessage = "" } }
        )) { Button("OK", role: .cancel) {} } message: { Text(errorMessage) }
    }

    @MainActor
    private func operatorSession() async throws -> Session {
        let session = try await SupabaseService.client.auth.session
        guard session.user.id.uuidString.lowercased() == operatorID else {
            throw NSError(domain: "MEETI", code: 403, userInfo: [
                NSLocalizedDescriptionKey: "指定された運営アカウントでログインしてください。"
            ])
        }
        return session
    }

    @MainActor
    private func load() async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        do {
            _ = try await operatorSession()
            // APIの1回あたりの返却上限を考慮し、小分けに取得する。
            var loaded: [Card] = []
            var offset = 0
            while true {
                let page: [Card] = try await SupabaseService.client.from("participants")
                    .select("id,number,nickname,mbti")
                    .order("number", ascending: false)
                    .range(from: offset, to: offset + 199)
                    .execute().value
                if page.isEmpty { break }
                loaded.append(contentsOf: page)
                offset += page.count
            }
            cards = loaded
        } catch {
            cards = []
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func delete(_ card: Card) async {
        guard !busy else { return }
        busy = true
        notice = ""
        defer { busy = false }
        do {
            let session = try await operatorSession()
            let response: DeleteResponse = try await SupabaseService.client.functions.invoke(
                "meeti-delete-participant",
                options: FunctionInvokeOptions(
                    headers: ["Authorization": "Bearer \(session.accessToken)"],
                    body: ["participantID": card.id.uuidString]
                )
            )
            guard response.deleted else {
                throw NSError(domain: "MEETI", code: 500, userInfo: [
                    NSLocalizedDescriptionKey: "削除結果を確認できませんでした。更新して確認してください。"
                ])
            }
            cards.removeAll { $0.id == card.id }
            notice = "No. \(card.number)をサーバーから削除しました。"
            // この端末に保存された同じ参加者も削除する。
            do {
                let id = card.id
                let descriptor = FetchDescriptor<Participant>(
                    predicate: #Predicate { $0.remoteID == id }
                )
                for participant in try modelContext.fetch(descriptor) {
                    modelContext.delete(participant)
                }
                try modelContext.save()
            } catch {
                errorMessage = "サーバーからは削除済みですが、この端末内のデータ整理に失敗しました。"
            }
        } catch FunctionsError.httpError(let code, let data) {
            errorMessage = "削除エラー（\(code)）: \(String(data: data, encoding: .utf8) ?? "詳細なし")。途中まで削除されている可能性があります。更新して確認し、残っていれば再試行してください。"
        } catch {
            errorMessage = "削除を確認できませんでした。更新して確認してください。\n\(error.localizedDescription)"
        }
    }
}
