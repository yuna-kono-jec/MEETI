//
//  MBTIResultView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI
import SwiftData

struct MBTIResultView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var savedParticipant: Participant?
    @State private var showBusinessCard = false
    @State private var isSaving = false
    @State private var saveError = ""
    
    var nickname: String
    var interests: [String]
    var message: String
    var gender: String
    var ageGroup: String
    var mbti: String
    var photoData: Data?
    
    @MainActor
    private func saveParticipant() async {
        guard !isSaving else { return }

        isSaving = true
        saveError = ""

        defer {
            isSaving = false
        }

        do {
            // Supabaseで保存してから、この端末にも残す
            let participant = try await ParticipantSyncService.saveParticipant(
                nickname: nickname,
                mbti: mbti,
                interests: interests,
                message: message,
                gender: gender,
                ageGroup: ageGroup,
                photoData: photoData
            )

            modelContext.insert(participant)
            try modelContext.save()

            savedParticipant = participant
            showBusinessCard = true
        } catch {
            let detail = String(reflecting: error)
            print("MEETI保存エラー: \(detail)")
            saveError = "名刺の保存処理で失敗しました。\n\(detail)"
        }
    }
    
    var body: some View {
        // 診断結果のタイプ名でAssetsの画像を表示する
        MEETIScreen(eyebrow: "03 / RESULT", title: "あなたのタイプ", subtitle: "あなたらしさを、名刺に添えて。") {
            VStack(spacing: 24) {
                Text(mbti).font(.system(size: 40, weight: .medium, design: .rounded)).tracking(6).foregroundStyle(MEETIStyle.green)
                MEETITypeImage(type: mbti)
                Text("好きなことも、あなたの個性のひとつ。\n次は自己紹介カードを作りましょう。")
                    .multilineTextAlignment(.center).font(.subheadline).lineSpacing(6)
            }.frame(maxWidth: .infinity).meetiCard()
            Button {
                Task {
                    await saveParticipant()
                }
            } label: {
                if isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("名刺を作る")
                }
            }
            .buttonStyle(MEETIButtonStyle())
            .disabled(isSaving)
        }
        .navigationDestination(isPresented: $showBusinessCard) {
            if let participant = savedParticipant {
                BusinessCardView(participant: participant)
            }
        }
        .alert("保存できませんでした", isPresented: Binding(
            get: { !saveError.isEmpty },
            set: { if !$0 { saveError = "" } }
        )) {
            Button("OK") {}
        } message: {
            Text(saveError)
        }
    }
}

#Preview {
    MBTIResultView(
        nickname: "ゆな",
        interests: ["ゲーム", "犬", "旅行"],
        message: "よろしく！",
        gender: "女性",
        ageGroup: "20〜29歳",
        mbti: "ENTJ",
        photoData: nil
    )
}
