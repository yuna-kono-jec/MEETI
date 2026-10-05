import Foundation

// MBTIの質問1問分
struct MBTIQuestion {
    var text: String
    var optionA: String
    var optionB: String
    var optionAType: String
    var optionBType: String
}

// 診断で使う12問
let mbtiQuestions: [MBTIQuestion] = [

    // E / I
    MBTIQuestion(
        text: "初対面の人が多い場所では？",
        optionA: "気になる人には自分から話しかける",
        optionB: "まず様子を見て、話しかけられるのを待つ",
        optionAType: "E",
        optionBType: "I"
    ),

    MBTIQuestion(
        text: "疲れた日の過ごし方は？",
        optionA: "誰かと話したり出かけたりしたい",
        optionB: "一人でゆっくり過ごしたい",
        optionAType: "E",
        optionBType: "I"
    ),

    MBTIQuestion(
        text: "楽しいことがあったときは？",
        optionA: "すぐ誰かに話したくなる",
        optionB: "まず自分の中でじっくり楽しむ",
        optionAType: "E",
        optionBType: "I"
    ),

    // S / N
    MBTIQuestion(
        text: "説明を聞くなら？",
        optionA: "具体例や実際のやり方がある方が分かりやすい",
        optionB: "まず全体像や「なぜそうなるか」を知りたい",
        optionAType: "S",
        optionBType: "N"
    ),

    MBTIQuestion(
        text: "旅行の計画を立てているときは？",
        optionA: "場所・時間・交通手段など現実的な情報を調べる",
        optionB: "こんなことできたら楽しそうとアイデアが広がる",
        optionAType: "S",
        optionBType: "N"
    ),

    MBTIQuestion(
        text: "映画や物語を見たあと、気になりやすいのは？",
        optionA: "印象的だった場面や登場人物の行動",
        optionB: "作品に込められた意味や伏線・考察",
        optionAType: "S",
        optionBType: "N"
    ),

    // T / F
    MBTIQuestion(
        text: "友達から悩みを相談されたら？",
        optionA: "どうすれば解決できるか一緒に考える",
        optionB: "まず相手の気持ちを聞いて寄り添う",
        optionAType: "T",
        optionBType: "F"
    ),

    MBTIQuestion(
        text: "グループで意見が割れたら？",
        optionA: "一番合理的な案を選びたい",
        optionB: "みんなが納得できる案を探したい",
        optionAType: "T",
        optionBType: "F"
    ),

    MBTIQuestion(
        text: "誰かに注意しなければならないときは？",
        optionA: "必要なことならはっきり伝える",
        optionB: "相手がどう感じるかを考えて伝え方を選ぶ",
        optionAType: "T",
        optionBType: "F"
    ),

    // J / P
    MBTIQuestion(
        text: "予定のない休日は？",
        optionA: "前日までに何をするかある程度決めたい",
        optionB: "その日の気分で決めたい",
        optionAType: "J",
        optionBType: "P"
    ),

    MBTIQuestion(
        text: "締切が1週間後の課題が出たら？",
        optionA: "早めに取りかかって余裕を持って終わらせたい",
        optionB: "締切に間に合えば自分のペースで進めたい",
        optionAType: "J",
        optionBType: "P"
    ),

    MBTIQuestion(
        text: "旅行に行くなら？",
        optionA: "行きたい場所や時間をある程度決めておきたい",
        optionB: "大まかに決めて現地で自由に動きたい",
        optionAType: "J",
        optionBType: "P"
    )
]
