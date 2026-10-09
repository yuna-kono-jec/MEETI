import SwiftUI

// 終了操作を末端のQR画面まで環境経由で共有し、各画面のParticipant引数は変更しません。
extension EnvironmentValues {
    @Entry var finishMEETIExperience: (() -> Void)? = nil
}

struct StartView: View {
    // この状態はNavigationStackの外に保持し、終了時に新しい画面ツリーを作ります。
    @State private var experienceID = UUID()

    var body: some View {
        // 既存のNavigationStackとProfileInputViewへの遷移を維持します。
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    // 参考画像①の中央付近にロゴから開始ボタンまでを小さくまとめます。
                    // 端末の高さに合わせるのは上下の余白だけで、文字や花は拡大しません。
                    VStack(spacing: 0) {
                        Spacer(minLength: 20)
                        welcomeContent
                        Spacer(minLength: 20)
                    }
                    .frame(minHeight: geometry.size.height)
                    .frame(maxWidth: .infinity)
                }.scrollBounceBehavior(.basedOnSize)
            }
            .background {
                ZStack(alignment: .topLeading) {
                    MEETIStyle.ivory
                    // 参考画像の左上〜左側の植物を、淡いぼかしと枝・小さな葉で表現します。
                    StartEdgeBotanical().frame(width: 145, height: 380)
                        .blur(radius: 3).opacity(0.42).offset(x: -25, y: 15)
                }.ignoresSafeArea()
            }
            .foregroundStyle(MEETIStyle.ink)
            .tint(MEETIStyle.green)
        }
        // 識別子の更新でスタック全体を破棄し、戻る履歴・入力・診断の一時状態をリセットします。
        // アプリ上位のSwiftDataコンテナと保存済みParticipantには触れません。
        .id(experienceID)
        .environment(\.finishMEETIExperience, {
            experienceID = UUID()
        })
    }

    // 参考画像にあるロゴ・説明・小花・ボタンだけを表示します。
    // 機能紹介の3項目、紹介カード、WELCOME、独自のキャッチコピーは設けません。
    var welcomeContent: some View {
        VStack(spacing: 0) {
            Text("MEETI.")
                .font(.system(size: 31, weight: .light)).tracking(6)
            Text("MBTI診断 × 自己紹介カード\nで、あたらしい出会いを。")
                .font(.system(size: 11)).lineSpacing(5)
                .multilineTextAlignment(.center).foregroundStyle(.secondary)
                .padding(.top, 14)
            // 花の線画は説明の下に小さく添え、主役のロゴより目立たせません。
            StartBotanicalIllustration().frame(width: 115, height: 60)
                .opacity(0.75).padding(.top, 15).padding(.bottom, 20)
            NavigationLink { ProfileInputView() } label: {
                HStack {
                    Spacer()
                    Text("はじめる").font(.system(size: 15, weight: .regular))
                    Spacer()
                    Image(systemName: "arrow.right").font(.system(size: 13, weight: .light))
                }
                .padding(.horizontal, 22).frame(height: 48)
                .foregroundStyle(.white)
                .background(MEETIStyle.green.opacity(0.85), in: Capsule())
            }.buttonStyle(.plain)
        }
        .frame(maxWidth: 290).padding(.horizontal, 28)
    }
}

// 背景専用の枝ものです。SF Symbolsや円形の背景を使用せず、葉を細い枝に沿わせます。
private struct StartEdgeBotanical: View {
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 145, y: size.height / 380)
            let green = Color(red: 0.58, green: 0.65, blue: 0.55)
            // 3本の枝の各ベジェ曲線から葉の位置を求め、自然な斜めの流れにします。
            let branches: [(CGPoint, CGPoint, CGFloat)] = [
                (CGPoint(x: 5, y: 340), CGPoint(x: 87, y: 16), CGFloat(22)),
                (CGPoint(x: 2, y: 230), CGPoint(x: 112, y: 90), CGFloat(18)),
                (CGPoint(x: 4, y: 365), CGPoint(x: 103, y: 294), CGFloat(24))
            ]
            for (base, tip, bend) in branches {
                let control = CGPoint(x: base.x + bend, y: tip.y + 60)
                var branch = Path(); branch.move(to: base)
                branch.addQuadCurve(to: tip, control: control)
                context.stroke(branch, with: .color(green.opacity(0.6)), style: StrokeStyle(lineWidth: 0.9, lineCap: .round))
                for index in 1...7 {
                    let t = CGFloat(index) / 9
                    let u = 1 - t
                    let baseWeight = u * u
                    let controlWeight = 2 * u * t
                    let tipWeight = t * t
                    let anchorX = baseWeight * base.x + controlWeight * control.x + tipWeight * tip.x
                    let anchorY = baseWeight * base.y + controlWeight * control.y + tipWeight * tip.y
                    let anchor = CGPoint(x: anchorX, y: anchorY)
                    let direction: CGFloat = index.isMultiple(of: 2) ? 1 : -1
                    let end = CGPoint(x: anchor.x + direction * 25, y: anchor.y - 19)
                    var leaf = Path(); leaf.move(to: anchor)
                    leaf.addQuadCurve(to: end, control: CGPoint(x: anchor.x + direction * 30, y: anchor.y - 2))
                    leaf.addQuadCurve(to: anchor, control: CGPoint(x: anchor.x + direction * 7, y: anchor.y - 26))
                    context.fill(leaf, with: .color(green.opacity(0.45)))
                }
            }
        }.accessibilityHidden(true).allowsHitTesting(false)
    }
}

// カフェのショップカードやウェディングペーパーをイメージした、控えめな植物の線画です。
// 各茎の傾きと花の高さを変え、単体の大きな葉ではなく小さな野花の束にします。
private struct StartBotanicalIllustration: View {
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 220, y: size.height / 175)
            let sage = Color(red: 0.53, green: 0.59, blue: 0.51)
            let greige = Color(red: 0.63, green: 0.60, blue: 0.53)
            func line(_ path: Path, color: Color = sage, width: CGFloat = 0.7) {
                context.stroke(path, with: .color(color.opacity(0.8)), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
            }
            // ゆるく曲がった細い茎を、中央の根元から少しずつ広げます。
            func stem(from base: CGPoint, to tip: CGPoint, bend: CGFloat) {
                var path = Path()
                path.move(to: base)
                path.addCurve(to: tip,
                              control1: CGPoint(x: base.x + bend, y: 123),
                              control2: CGPoint(x: tip.x - bend * 0.4, y: tip.y + 37))
                line(path)
            }
            // 小さな葉には薄い塗りと中央の葉脈を加え、輪郭の主張を抑えます。
            func leaf(at base: CGPoint, to tip: CGPoint) {
                let dx = tip.x - base.x
                let dy = tip.y - base.y
                var path = Path()
                path.move(to: base)
                path.addQuadCurve(to: tip, control: CGPoint(x: base.x + dx * 0.85 - dy * 0.2, y: base.y + dy * 0.5 + dx * 0.2))
                path.addQuadCurve(to: base, control: CGPoint(x: base.x + dx * 0.2 + dy * 0.16, y: base.y + dy * 0.5 - dx * 0.16))
                context.fill(path, with: .color(sage.opacity(0.10)))
                line(path, width: 0.55)
                var vein = Path()
                vein.move(to: base); vein.addLine(to: tip)
                line(vein, width: 0.35)
            }
            // 花は細い輪郭の5枚の花弁と、非常に淡いベージュの中心で描きます。
            func flower(at center: CGPoint, radius: CGFloat, angle: Double) {
                for index in 0..<5 {
                    let rotation = Double(index) * .pi * 2 / 5 + angle
                    var petalContext = context
                    petalContext.translateBy(x: center.x, y: center.y)
                    petalContext.rotate(by: .radians(rotation))
                    let petal = Path(ellipseIn: CGRect(x: -radius * 0.42, y: -radius * 1.35, width: radius * 0.84, height: radius * 1.18))
                    petalContext.stroke(petal, with: .color(greige.opacity(0.7)), style: StrokeStyle(lineWidth: 0.65))
                }
                let middle = Path(ellipseIn: CGRect(x: center.x - 1.5, y: center.y - 1.5, width: 3, height: 3))
                context.fill(middle, with: .color(MEETIStyle.beige.opacity(0.65)))
            }
            stem(from: CGPoint(x: 104, y: 162), to: CGPoint(x: 68, y: 50), bend: -12)
            stem(from: CGPoint(x: 109, y: 160), to: CGPoint(x: 99, y: 27), bend: 3)
            stem(from: CGPoint(x: 113, y: 162), to: CGPoint(x: 137, y: 42), bend: 10)
            stem(from: CGPoint(x: 117, y: 163), to: CGPoint(x: 162, y: 73), bend: 19)
            stem(from: CGPoint(x: 101, y: 161), to: CGPoint(x: 47, y: 93), bend: -22)
            // 葉の根元を茎と同じベジェ曲線上で計算し、葉が浮いて見えないようにします。
            func attachedLeaf(base: CGPoint, tip: CGPoint, bend: CGFloat, t: CGFloat, direction: CGFloat) {
                let c1 = CGPoint(x: base.x + bend, y: 123)
                let c2 = CGPoint(x: tip.x - bend * 0.4, y: tip.y + 37)
                let u = 1 - t
                let anchor = CGPoint(
                    x: u*u*u*base.x + 3*u*u*t*c1.x + 3*u*t*t*c2.x + t*t*t*tip.x,
                    y: u*u*u*base.y + 3*u*u*t*c1.y + 3*u*t*t*c2.y + t*t*t*tip.y)
                leaf(at: anchor, to: CGPoint(x: anchor.x + direction * 15, y: anchor.y - 17))
            }
            attachedLeaf(base: CGPoint(x: 104, y: 162), tip: CGPoint(x: 68, y: 50), bend: -12, t: 0.43, direction: -1)
            attachedLeaf(base: CGPoint(x: 104, y: 162), tip: CGPoint(x: 68, y: 50), bend: -12, t: 0.69, direction: 1)
            attachedLeaf(base: CGPoint(x: 109, y: 160), tip: CGPoint(x: 99, y: 27), bend: 3, t: 0.42, direction: -1)
            attachedLeaf(base: CGPoint(x: 109, y: 160), tip: CGPoint(x: 99, y: 27), bend: 3, t: 0.66, direction: 1)
            attachedLeaf(base: CGPoint(x: 113, y: 162), tip: CGPoint(x: 137, y: 42), bend: 10, t: 0.41, direction: 1)
            attachedLeaf(base: CGPoint(x: 113, y: 162), tip: CGPoint(x: 137, y: 42), bend: 10, t: 0.66, direction: -1)
            attachedLeaf(base: CGPoint(x: 117, y: 163), tip: CGPoint(x: 162, y: 73), bend: 19, t: 0.5, direction: 1)
            attachedLeaf(base: CGPoint(x: 101, y: 161), tip: CGPoint(x: 47, y: 93), bend: -22, t: 0.54, direction: -1)
            flower(at: CGPoint(x: 68, y: 48), radius: 6, angle: 0.2)
            flower(at: CGPoint(x: 99, y: 25), radius: 7, angle: -0.1)
            flower(at: CGPoint(x: 137, y: 40), radius: 5, angle: 0.5)
            flower(at: CGPoint(x: 162, y: 72), radius: 4, angle: 0.1)
            flower(at: CGPoint(x: 47, y: 92), radius: 4, angle: -0.3)
            // 根元を結ぶ短い線を添え、束ねた野花の自然なまとまりを作ります。
            var tie = Path()
            tie.move(to: CGPoint(x: 99, y: 151))
            tie.addQuadCurve(to: CGPoint(x: 121, y: 152), control: CGPoint(x: 110, y: 156))
            line(tie, color: greige, width: 0.55)
        }
        .accessibilityHidden(true).allowsHitTesting(false)
    }
}


#Preview { StartView() }
