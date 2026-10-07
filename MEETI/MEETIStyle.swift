import SwiftUI
import UIKit

// 全画面で使用する配色。診断や保存のロジックには依存しません。
enum MEETIStyle {
    static let ivory = Color(red: 0.98, green: 0.97, blue: 0.94)
    static let green = Color(red: 0.43, green: 0.56, blue: 0.46)
    static let ink = Color(red: 0.25, green: 0.31, blue: 0.27)
    static let pink = Color(red: 0.95, green: 0.86, blue: 0.85)
    static let blue = Color(red: 0.85, green: 0.91, blue: 0.93)
    static let beige = Color(red: 0.93, green: 0.89, blue: 0.81)
}

// 小さい画面や文字サイズの変更でも内容を読める共通スクロール画面です。
struct MEETIScreen<Content: View>: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    // 名刺の見出しだけを大きくできるよう、画面ごとに指定します。
    var eyebrowFont: Font = .caption
    @ViewBuilder var content: () -> Content
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(spacing: 8) {
                    Text(eyebrow.components(separatedBy: " / ").last ?? eyebrow).font(eyebrowFont).tracking(3).foregroundStyle(MEETIStyle.green)
                    if !title.isEmpty { Text(title).font(.system(size: 21, weight: .medium, design: .rounded)) }
                    if !subtitle.isEmpty { Text(subtitle).multilineTextAlignment(.center).font(.caption).foregroundStyle(.secondary).lineSpacing(5) }
                }
                .frame(maxWidth: .infinity)
                content()
            }
            .frame(maxWidth: 520, alignment: .leading)
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .background(MEETIStyle.ivory.ignoresSafeArea())
        .foregroundStyle(MEETIStyle.ink)
        .tint(MEETIStyle.green)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 主な操作ボタンの大きさと押下・無効状態を統一します。
struct MEETIButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 15, weight: .medium))
            .frame(maxWidth: .infinity).padding(.vertical, 15).padding(.horizontal, 16)
            .foregroundStyle(.white)
            .background(MEETIStyle.green.opacity(isEnabled ? (configuration.isPressed ? 0.75 : 1) : 0.4))
            .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}

extension View {
    // 入力欄や名刺の枠に使う、細い線の角丸カードです。
    func meetiCard() -> some View {
        self.padding(20).frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(MEETIStyle.green.opacity(0.15), lineWidth: 1))
    }
}

// Assets内のタイプ名と同じ画像を表示し、装飾画像の読み上げを省きます。
struct MEETITypeImage: View {
    let type: String
    var body: some View {
        Image(type.uppercased()).resizable().scaledToFit().frame(height: 180)
            .frame(maxWidth: .infinity).accessibilityHidden(true)
    }
}

// 保存済みの写真がある場合はそれを表示し、未登録時はMBTI画像を使います。
struct MEETIAvatar: View {
    let participant: Participant
    var size: CGFloat = 130
    var body: some View {
        Group {
            if let data = participant.photoData, let photo = UIImage(data: data) {
                Image(uiImage: photo).resizable().scaledToFill()
            } else {
                Image(participant.mbti.uppercased()).resizable().scaledToFit()
            }
        }.frame(width: size, height: size)
            .background(MEETIStyle.beige.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 16)).accessibilityHidden(true)
    }
}

// お手本の淡い3色のタグを共通部品として表示します。
struct MEETIInterestTags: View {
    let interests: [String]
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 8) {
            ForEach(Array(interests.enumerated()), id: \.offset) { index, interest in
                Label(interest, systemImage: interestIcon(interest)).font(.caption).padding(.vertical, 7).padding(.horizontal, 10)
                    .frame(maxWidth: .infinity)
                    .background([MEETIStyle.pink, MEETIStyle.blue, MEETIStyle.beige][index % 3].opacity(0.7), in: Capsule())
            }
        }
    }
    // 登録済みの趣味を、お手本のアイコン付きタグとして表示します。
    private func interestIcon(_ interest: String) -> String {
        let icons = ["音楽": "music.note", "旅行": "airplane", "カフェ": "cup.and.saucer", "読書": "book", "映画": "film", "ゲーム": "gamecontroller", "アニメ": "tv", "スポーツ": "figure.run", "犬": "pawprint", "猫": "pawprint", "アート": "paintpalette", "グルメ": "fork.knife", "アウトドア": "mountain.2", "ショッピング": "bag"]
        return icons[interest] ?? "heart"
    }

}

// 表示専用の日本語タイプ名です。診断・相性計算の値には影響しません。
// 名刺画面でも同じ表示名を再利用します。
let meetiTypeNames = [
    "ISTJ": "管理者", "ISFJ": "擁護者", "INFJ": "提唱者", "INTJ": "建築家",
    "ISTP": "巨匠", "ISFP": "冒険家", "INFP": "仲介者", "INTP": "論理学者",
    "ESTP": "起業家", "ESFP": "エンターテイナー", "ENFP": "運動家", "ENTP": "討論者",
    "ESTJ": "幹部", "ESFJ": "領事", "ENFJ": "主人公", "ENTJ": "指揮官"
]

// お手本の植物を、拡大しても粗くならない曲線で描く装飾です。
// 茎・葉・花を独立したパスにし、写真や文字には重ねません。
// 名刺専用レイアウトからも既存の花を再利用します。
struct MEETICardSprig: View {
    enum Kind { case foliage, tulip, wildflowers }
    var kind: Kind = .foliage

    var body: some View {
        Canvas { context, size in
            // 60×100の座標を表示サイズに合わせ、細い線と淡い塗りを保ちます。
            context.scaleBy(x: size.width / 60, y: size.height / 100)
            let green = MEETIStyle.green.opacity(0.5)
            let pink = Color(red: 0.89, green: 0.59, blue: 0.63)
            func stroke(_ path: Path, _ color: Color = green) {
                context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 0.9, lineCap: .round, lineJoin: .round))
            }
            func stem(_ x: CGFloat, _ top: CGFloat, _ bend: CGFloat) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 96))
                path.addQuadCurve(to: CGPoint(x: x + bend, y: top), control: CGPoint(x: x - 5, y: 60))
                stroke(path)
            }
            func leaf(_ x: CGFloat, _ y: CGFloat, _ direction: CGFloat, _ length: CGFloat = 16) {
                var path = Path()
                let start = CGPoint(x: x, y: y)
                let tip = CGPoint(x: x + direction * 13, y: y - length)
                path.move(to: start)
                path.addQuadCurve(to: tip, control: CGPoint(x: x + direction * 19, y: y - 3))
                path.addQuadCurve(to: start, control: CGPoint(x: x + direction * 2, y: y - length))
                context.fill(path, with: .color(green.opacity(0.45)))
                stroke(path)
            }
            // 先端が3つに分かれた花弁と、その中央の細い線でチューリップを描きます。
            func tulip(_ x: CGFloat, _ y: CGFloat, _ filled: Bool) {
                var petals = Path()
                petals.move(to: CGPoint(x: x, y: y + 23))
                petals.addCurve(to: CGPoint(x: x - 10, y: y), control1: CGPoint(x: x - 12, y: y + 19), control2: CGPoint(x: x - 13, y: y + 4))
                petals.addQuadCurve(to: CGPoint(x: x - 3, y: y + 4), control: CGPoint(x: x - 5, y: y - 4))
                petals.addQuadCurve(to: CGPoint(x: x + 3, y: y + 4), control: CGPoint(x: x, y: y - 8))
                petals.addQuadCurve(to: CGPoint(x: x + 10, y: y), control: CGPoint(x: x + 7, y: y - 4))
                petals.addCurve(to: CGPoint(x: x, y: y + 23), control1: CGPoint(x: x + 14, y: y + 10), control2: CGPoint(x: x + 8, y: y + 23))
                if filled { context.fill(petals, with: .color(MEETIStyle.pink.opacity(0.7))) }
                stroke(petals, filled ? pink.opacity(0.65) : green)
                var veins = Path()
                veins.move(to: CGPoint(x: x - 3, y: y + 4))
                veins.addQuadCurve(to: CGPoint(x: x, y: y + 22), control: CGPoint(x: x - 4, y: y + 15))
                veins.move(to: CGPoint(x: x + 3, y: y + 4))
                veins.addQuadCurve(to: CGPoint(x: x, y: y + 22), control: CGPoint(x: x + 4, y: y + 15))
                stroke(veins, filled ? pink.opacity(0.55) : green)
            }
            switch kind {
            case .foliage:
                stem(29, 12, 5)
                for index in 0..<5 {
                    let y = CGFloat(85 - index * 14)
                    leaf(29, y, index.isMultiple(of: 2) ? -1 : 1)
                }
                leaf(31, 26, 0.5, 18)
            case .tulip:
                stem(30, 35, 0)
                leaf(30, 85, -1, 30)
                leaf(30, 87, 1, 27)
                tulip(30, 12, true)
            case .wildflowers:
                stem(20, 39, -2)
                stem(36, 24, 3)
                leaf(20, 78, -1, 14)
                leaf(35, 68, 1, 13)
                tulip(39, 8, false)
                // 小花は5枚の小さな花弁を輪郭だけで描きます。
                for index in 0..<5 {
                    let angle = Double(index) * .pi * 2 / 5
                    let center = CGPoint(x: 18 + cos(angle) * 5, y: 31 + sin(angle) * 5)
                    stroke(Path(ellipseIn: CGRect(x: center.x - 3, y: center.y - 4, width: 6, height: 8)))
                }
            }
        }.frame(width: kind == .foliage ? 35 : 42, height: kind == .foliage ? 85 : 70)
            .accessibilityHidden(true).allowsHitTesting(false)
    }
}

// 新しいお手本の、番号・画像・名前・タグ・ひとこと・ロゴの順で名刺を表示します。
struct MEETIParticipantCard: View {
    let participant: Participant
    var body: some View {
        VStack(spacing: 15) {
            HStack(alignment: .top) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("No.").font(.caption)
                    Text(String(format: "%03d", participant.number)).font(.title2.weight(.semibold).monospacedDigit())
                }.foregroundStyle(MEETIStyle.green)
                Spacer()
                Text("よろしく\nお願いします！ ♡").font(.caption).lineSpacing(4)
                    .rotationEffect(.degrees(-8)).foregroundStyle(MEETIStyle.ink.opacity(0.75))
            }
            // 実物写真とMBTI画像を重ねず、登録済み写真の有無で一方だけを表示します。
            MEETIAvatar(participant: participant, size: 210)
            HStack(alignment: .center) {
                MEETICardSprig()
                Spacer(minLength: 8)
                VStack(spacing: 6) {
                    Text(participant.nickname).font(.system(size: 26, weight: .semibold, design: .rounded)).tracking(2)
                    Text(typeLabel).font(.subheadline).foregroundStyle(MEETIStyle.green).multilineTextAlignment(.center)
                }
                Spacer(minLength: 8)
                MEETICardSprig().scaleEffect(x: -1, y: 1)
            }
            MEETIInterestTags(interests: participant.interests)
            // 本人のメッセージだけを表示し、空欄の場合も入力を捏造しません。
            if !participant.message.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("ひとこと", systemImage: "message.fill").font(.caption).foregroundStyle(MEETIStyle.green)
                    Text(participant.message).font(.subheadline).lineSpacing(5)
                        .frame(maxWidth: .infinity, alignment: .center)
                // 右側に花のための余白を確保し、長いメッセージと重ならないようにします。
                }.padding(14).padding(.trailing, 32)
                    .background(MEETIStyle.ivory.opacity(0.65), in: RoundedRectangle(cornerRadius: 16))
                    .overlay(alignment: .bottomTrailing) {
                        MEETICardSprig(kind: .tulip).padding(.trailing, 2).padding(.bottom, 3)
                    }
            }
            HStack {
                MEETICardSprig(kind: .wildflowers)
                Spacer()
                VStack(spacing: 5) {
                    Text("MEETI.").font(.system(size: 18, weight: .light)).tracking(4)
                    Text("Meet your type.").font(.system(size: 9)).tracking(1)
                }.foregroundStyle(MEETIStyle.green)
                Spacer()
                MEETICardSprig(kind: .wildflowers).scaleEffect(x: -1, y: 1)
            }.padding(.top, 4).accessibilityHidden(true)
        }.frame(maxWidth: .infinity).meetiCard()
    }

    // 保存されているタイプ文字列を維持し、日本語名のみ補足します。
    private var typeLabel: String {
        guard let name = meetiTypeNames[participant.mbti.uppercased()] else { return participant.mbti }
        return "\(participant.mbti) / \(name)タイプ"
    }
}
