import SwiftUI
import UIKit

struct BusinessCardView: View {
    var participant: Participant

    var body: some View {
        // カードとボタンを同じ縦並びに置き、画面下部への固定による大きな空白をなくします。
        ScrollView {
            VStack(spacing: 12) {
                Text("MY CARD")
                    .font(.system(size: 21, weight: .regular)).tracking(3)
                    .foregroundStyle(MEETIStyle.green)
                VStack(spacing: 10) {
                    compactCard(imageSize: 160)
                    // 保存・遷移の処理は維持し、名刺の直下からMatchingViewへ進みます。
                    NavigationLink { MatchingView(participant: participant) } label: {
                        HStack {
                            Spacer()
                            Text("この内容で登録する")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                    }.buttonStyle(MEETIButtonStyle())
                }
            }
            .frame(maxWidth: 340).padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 20)
            .frame(maxWidth: .infinity)
        }
        // 長い文章や大きな文字設定では、カードとボタンを一緒にスクロールできます。
        .scrollBounceBehavior(.basedOnSize)
        .background(MEETIStyle.ivory.ignoresSafeArea())
        .foregroundStyle(MEETIStyle.ink)
        .tint(MEETIStyle.green)
        .navigationBarTitleDisplayMode(.inline)
    }

    // お手本に合わせて、この画面だけ小さな間隔とコンパクトな画像で名刺を組み立てます。
    private func compactCard(imageSize: CGFloat) -> some View {
        VStack(spacing: 8) {
            HStack(alignment: .top) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("No.").font(.system(size: 13))
                    Text(String(format: "%03d", participant.number)).font(.system(size: 22, weight: .semibold).monospacedDigit())
                }.foregroundStyle(MEETIStyle.green)
                Spacer()
                Text("よろしく\nお願いします！ ♡").font(.system(size: 11)).lineSpacing(3)
                    .rotationEffect(.degrees(-8))
            }
            // 画像・名前・タイプを1つのプロフィールブロックにし、画像下の間隔を3ptにします。
            VStack(spacing: 3) {
                // 写真を復元できる場合は写真だけを表示。写真なしの場合に背景の四角い枠は付けません。
                if let data = participant.photoData, let photo = UIImage(data: data) {
                    Image(uiImage: photo).resizable().scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(RoundedRectangle(cornerRadius: 14)).accessibilityHidden(true)
                } else {
                    // 固定タイプではなく、参加者本人のMBTI名に対応した既存Assetsを使用します。
                    Image(participant.mbti.uppercased()).resizable().scaledToFit()
                        .frame(width: imageSize + 20, height: imageSize)
                        // Assets内の周囲の余白を表示枠で抑え、イラスト直下に名前を寄せます。
                        .scaleEffect(1.12)
                        .frame(width: imageSize + 20, height: imageSize - 24)
                        .clipped().accessibilityHidden(true)
                }
                Text(participant.nickname).font(.system(size: 25, weight: .semibold, design: .rounded))
                    .tracking(1).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                Text(typeLabel).font(.system(size: 12)).foregroundStyle(MEETIStyle.green)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            // 名前の左右への直立した装飾は撤去し、植物はカード全体の端に配置します。
            .padding(.horizontal, 18)

            // 趣味タグは内容に必要な幅だけ使い、3つを中央寄せで並べます。
            HStack(alignment: .center, spacing: 6) {
                ForEach(Array(participant.interests.enumerated()), id: \.offset) { index, interest in
                    Text(interest).font(.system(size: 11)).multilineTextAlignment(.center)
                        .padding(.vertical, 5).padding(.horizontal, 10)
                        .background([MEETIStyle.pink, MEETIStyle.blue, MEETIStyle.beige][index % 3].opacity(0.7), in: Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            // 独立したひとこと欄は未入力でも枠を保ち、ロゴと一枚の名刺にまとまる密度にします。
            VStack(alignment: .leading, spacing: 5) {
                Label("ひとこと", systemImage: "message.fill").font(.system(size: 11)).foregroundStyle(MEETIStyle.green)
                Text(participant.message.isEmpty ? " " : participant.message)
                    .font(.system(size: 12)).lineSpacing(2).multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity)
            }
            .padding(.vertical, 9).padding(.leading, 11).padding(.trailing, 32)
            .background(MEETIStyle.ivory.opacity(0.65), in: RoundedRectangle(cornerRadius: 14))
            // チューリップも右端から斜めに覗かせ、メッセージ本文には重ねません。
            .overlay(alignment: .bottomTrailing) {
                smallFlower(.tulip).rotationEffect(.degrees(-32)).offset(x: 7, y: 4)
            }
            HStack {
                Spacer()
                VStack(spacing: 2) {
                    Text("MEETI.").font(.system(size: 16, weight: .light)).tracking(4)
                    Text("Meet your type.").font(.system(size: 8)).tracking(1)
                }.foregroundStyle(MEETIStyle.green)
                Spacer()
            }.frame(minHeight: 34).accessibilityHidden(true)
        }
        .padding(14).frame(maxWidth: .infinity)
        .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(MEETIStyle.green.opacity(0.1), lineWidth: 0.7))
        // 植物を情報の左右ではなく、紙の端から入り込む非対称な装飾として重ねます。
        .overlay {
            GeometryReader { geometry in
                ZStack {
                    // 左端から右上へ伸びる枝。根元はカード外に逃がします。
                    smallFlower(.foliage).scaleEffect(1.35)
                        .rotationEffect(.degrees(52))
                        .position(x: 4, y: geometry.size.height * 0.46)
                    // 右端の小花は左上を向け、左側と異なる高さ・長さにします。
                    smallFlower(.wildflowers).scaleEffect(1.1)
                        .rotationEffect(.degrees(-61))
                        .position(x: geometry.size.width - 3, y: geometry.size.height * 0.34)
                    // 左下の角から斜めに覗く野花。カード下端で一部を見切れさせます。
                    smallFlower(.wildflowers).scaleEffect(1.2)
                        .rotationEffect(.degrees(39))
                        .position(x: 17, y: geometry.size.height - 4)
                    // 右下は横方向の枝にし、野花と同じ向き・高さにしません。
                    smallFlower(.foliage).scaleEffect(1.15)
                        .rotationEffect(.degrees(-78))
                        .position(x: geometry.size.width - 7, y: geometry.size.height - 23)
                }
            }
            // 描画の端だけをカード形状で切り取り、装飾はボタンや文字の操作を妨げません。
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .opacity(0.8).accessibilityHidden(true).allowsHitTesting(false)
        }
    }

    // 他画面の花の大きさは変えず、名刺内だけ小さく配置します。
    private func smallFlower(_ kind: MEETICardSprig.Kind) -> some View {
        MEETICardSprig(kind: kind).scaleEffect(0.48).frame(width: 24, height: 34)
            .accessibilityHidden(true).allowsHitTesting(false)
    }

    // 表示専用の名称を補足し、Participantに保存されたMBTI値は変更しません。
    private var typeLabel: String {
        guard let name = meetiTypeNames[participant.mbti.uppercased()] else { return participant.mbti }
        return "\(participant.mbti) / \(name)タイプ"
    }
}

// 写真なしの異なるタイプをプレビューし、本人に対応する画像表示を確認できます。
#Preview("INFP・写真なし") {
    NavigationStack {
        BusinessCardView(participant: Participant(number: 12, nickname: "HANA", mbti: "INFP", interests: ["読書", "カフェ", "映画"], message: "いろんな人とお話ししたいです！"))
    }
}
#Preview("INTP・写真なし") {
    NavigationStack {
        BusinessCardView(participant: Participant(number: 25, nickname: "RYO", mbti: "INTP", interests: ["ゲーム", "アニメ", "音楽"], message: "気軽に話しかけてください！"))
    }
}
