import XCTest
import SwiftData
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
        XCTAssertTrue(MBTITypeData.isValid("ENFJ"))
        XCTAssertFalse(MBTITypeData.isValid("ABCD"))
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

        XCTAssertEqual(result?.mbtiScore, 70)
        XCTAssertEqual(result?.interestScore, 30)
        XCTAssertEqual(result?.totalScore, 100)
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

    func testBestMatchUsesSavedParticipants() throws {
        let schema = Schema([Participant.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        let context = ModelContext(container)

        let me = participant(1, "自分", "ENFJ", ["音楽"])
        let candidate = participant(2, "候補", "ENFJ", ["音楽"])
        context.insert(me)
        context.insert(candidate)

        let result = BestMatchCalculator.findBestMatches(
            participant: me,
            modelContext: context
        )

        XCTAssertEqual(result?.matches.first?.participant.nickname, "候補")
        XCTAssertEqual(result?.score, 80)
    }

    private func participant(
        _ number: Int,
        _ nickname: String,
        _ mbti: String,
        _ interests: [String]
    ) -> Participant {
        return Participant(
            number: number,
            nickname: nickname,
            mbti: mbti,
            interests: interests,
            message: "テスト"
        )
    }
}
