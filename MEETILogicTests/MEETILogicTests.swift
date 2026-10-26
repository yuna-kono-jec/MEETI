import XCTest
@testable import MEETILogic

final class MEETILogicTests: XCTestCase {

    func testQuestionCount() {
        XCTAssertEqual(mbtiQuestions.count, 12)
    }

    func testDiagnosisSessionReturnsENFJ() {
        var session = MBTIDiagnosisSession()
        let answers = [
            "A", "A", "B",
            "B", "B", "A",
            "B", "B", "A",
            "A", "A", "B"
        ]

        for answer in answers {
            XCTAssertTrue(session.selectAnswer(answer))
        }

        XCTAssertTrue(session.isComplete)
        XCTAssertEqual(session.calculateResult(), "ENFJ")
    }

    func testDiagnosisRejectsInvalidAnswer() {
        var session = MBTIDiagnosisSession()

        XCTAssertFalse(session.selectAnswer("C"))
        XCTAssertEqual(session.answers.count, 0)
    }

    func testThereAreSixteenMBTITypes() {
        XCTAssertEqual(mbtiTypes.count, 16)
    }

    func testInterestsCanSelectUpToThree() {
        var selection = InterestSelection()

        XCTAssertTrue(selection.toggle("音楽"))
        XCTAssertTrue(selection.toggle("旅行"))
        XCTAssertTrue(selection.toggle("猫"))
        XCTAssertFalse(selection.toggle("映画"))
        XCTAssertEqual(selection.selectedInterests.count, 3)

        XCTAssertTrue(selection.toggle("旅行"))
        XCTAssertFalse(selection.isSelected("旅行"))
    }

    func testCompatibilityCanReachOneHundred() {
        let first = participant(1, "ゆり", "ENFJ", ["音楽", "旅行", "猫"])
        let second = participant(2, "ゆな", "ENFJ", ["音楽", "旅行", "猫"])

        let result = CompatibilityCalculator.calculate(first: first, second: second)

        XCTAssertEqual(result.mbtiScore, 70)
        XCTAssertEqual(result.interestScore, 30)
        XCTAssertEqual(result.totalScore, 100)
    }

    func testBestMatchHandlesZeroAndTiedCandidates() {
        let me = participant(1, "自分", "ENFJ", ["音楽", "旅行"])
        let first = participant(2, "候補A", "ENFJ", ["音楽"])
        let second = participant(3, "候補B", "ENFJ", ["旅行"])

        XCTAssertNil(
            BestMatchCalculator.findBestMatches(
                participant: me,
                candidates: []
            )
        )

        let result = BestMatchCalculator.findBestMatches(
            participant: me,
            candidates: [me, first, second]
        )

        XCTAssertEqual(result?.matches.count, 2)
        XCTAssertEqual(result?.score, 80)
    }

    // iOS 16と同じCore Data経路でも、保存済み参加者から正しく計算できることを確認します。
    @MainActor
    func testBestMatchUsesSavedParticipants() throws {
        let store = try ParticipantStore(inMemory: true, forceCoreData: true)

        let me = participant(1, "自分", "ENFJ", ["音楽"])
        let candidate = participant(2, "候補", "ENFJ", ["音楽"])
        try store.save(me)
        try store.save(candidate)

        let result = BestMatchCalculator.findBestMatches(
            participant: me,
            participantStore: store
        )

        XCTAssertEqual(result?.matches.first?.participant.nickname, "候補")
        XCTAssertEqual(result?.score, 80)
    }

    func testBestMatchFiltersGenderAndAgeGroup() {
        let me = participant(1, "自分", "ENFJ", ["音楽"])
        let match = participant(2, "候補A", "ENFJ", ["音楽"], "男性", "20〜29歳")
        let differentGender = participant(3, "候補B", "ENFJ", ["音楽"], "女性", "20〜29歳")
        let differentAge = participant(4, "候補C", "ENFJ", ["音楽"], "男性", "30〜39歳")

        let result = BestMatchCalculator.findBestMatches(
            participant: me,
            candidates: [match, differentGender, differentAge],
            preferredGender: "男性",
            preferredAgeGroup: "20〜29歳"
        )

        XCTAssertEqual(result?.matches.count, 1)
        XCTAssertEqual(result?.matches.first?.participant.nickname, "候補A")
    }

    private func participant(
        _ number: Int,
        _ nickname: String,
        _ mbti: String,
        _ interests: [String],
        _ gender: String = "未回答",
        _ ageGroup: String = "未回答"
    ) -> ParticipantProfile {
        return ParticipantProfile(
            number: number,
            nickname: nickname,
            mbti: mbti,
            interests: interests,
            message: "テスト",
            gender: gender,
            ageGroup: ageGroup
        )
    }
}
