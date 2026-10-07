//
//  ProfileInputView.swift
//  MEETI
//
//  Created by ♡ on 2026/09/28.
//

import SwiftUI
import SwiftData
import UIKit

struct ProfileInputView: View {
    @State private var nickname = ""
    @State private var interests: [String] = []
    @State private var message = ""
    @State private var photoData: Data?
    @State private var showPhotoNotice = false
    @State private var showCamera = false
    @State private var showCameraUnavailable = false
    
    
    let interestOptions = [
        "音楽",
        "旅行",
        "カフェ",
        "映画",
        "アニメ",
        "スポーツ",
        "読書",
        "ゲーム",
        "ショッピング",
        "アウトドア",
        "グルメ",
        "犬",
        "猫",
        "アート"
    ]
    
    // 選択上限と次へ進める条件は既存のまま、入力欄をカード化します。
    var body: some View {
        MEETIScreen(eyebrow: "01 / PROFILE", title: "プロフィールを入力しよう", subtitle: "好きなことが、出会いのきっかけに。") {
            // MBTI決定前なので、写真がない場合は人物アイコンを表示します。
            VStack(spacing: 12) {
                Group {
                    if let data = photoData, let photo = UIImage(data: data) {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(MEETIStyle.green)
                    }
                }
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Button(photoData == nil ? "写真を撮る（任意）" : "写真を撮り直す") {
                    showPhotoNotice = true
                }
                .buttonStyle(MEETIButtonStyle())

                if photoData != nil {
                    Button("写真を削除", role: .destructive) {
                        photoData = nil
                    }
                }

                Text("写真がない場合は診断したMBTIの画像を使用します")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .meetiCard()
            VStack(alignment: .leading, spacing: 14) {
                Text("ニックネーム").font(.headline)
                TextField("ニックネームを入力", text: $nickname).padding(14)
                    .background(MEETIStyle.ivory, in: RoundedRectangle(cornerRadius: 12))
            }.meetiCard()
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("好きなこと").font(.headline)
                    Spacer()
                    Text("\(interests.count) / 3").font(.subheadline.monospacedDigit()).foregroundStyle(MEETIStyle.green)
                }
                Text("3つ選んでね").font(.caption).foregroundStyle(.secondary)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                    ForEach(interestOptions, id: \.self) { interest in
                        Button {
                            if interests.contains(interest) {
                                interests.removeAll { $0 == interest }
                            } else if interests.count < 3 {
                                interests.append(interest)
                            }
                        } label: {
                            Text(interests.contains(interest) ? "✓ \(interest)" : interest)
                                .font(.caption).padding(.vertical, 9).frame(maxWidth: .infinity)
                                .background(interests.contains(interest) ? MEETIStyle.green : MEETIStyle.beige.opacity(0.45), in: Capsule())
                                .foregroundStyle(interests.contains(interest) ? .white : MEETIStyle.ink)
                        }.buttonStyle(.plain)
                        .accessibilityAddTraits(interests.contains(interest) ? .isSelected : [])
                    }
                }
            }.meetiCard()
            VStack(alignment: .leading, spacing: 12) {
                Text("ひとこと").font(.headline)
                Text("話してみたいことを書いてみよう").font(.caption).foregroundStyle(.secondary)
                TextEditor(text: $message).scrollContentBackground(.hidden).frame(height: 100)
                    .padding(8).background(MEETIStyle.ivory, in: RoundedRectangle(cornerRadius: 12))
                    .accessibilityLabel("ひとこと")
            }.meetiCard()
            NavigationLink {
                MBTIQuestionView(
                    nickname: nickname,
                    interests: interests,
                    message: message,
                    photoData: photoData
                )
            } label: { Label("MBTIを決める", systemImage: "arrow.right") }
                .buttonStyle(MEETIButtonStyle()).disabled(interests.count != 3)
        }.scrollDismissesKeyboard(.interactively)
        .alert("写真を利用する前に", isPresented: $showPhotoNotice) {
            Button("キャンセル", role: .cancel) {}
            Button("同意して撮影") {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    showCamera = true
                } else {
                    showCameraUnavailable = true
                }
            }
        } message: {
            Text("撮影した写真は自己紹介カードに表示され、マッチングした相手からも見えます。写真はこの端末内のMEETIアプリ専用領域（SwiftData）に保存されます。マッチング表示以外の目的では使用せず、悪用しません。")
        }
        .alert("カメラを使用できません", isPresented: $showCameraUnavailable) {
            Button("OK") {}
        } message: {
            Text("カメラを利用できるiPhoneまたはiPadで撮影してください。")
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(photoData: $photoData)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ProfileInputView()
}
