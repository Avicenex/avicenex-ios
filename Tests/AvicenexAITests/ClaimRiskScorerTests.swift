import XCTest
@testable import AvicenexAI

final class ClaimRiskScorerTests: XCTestCase {
    func testDemoClaimsProduceCalculatedAssessments() {
        let store = ReviewStore()
        let assessments = AvicenexDemoData.claims.map { store.assessment(for: $0) }

        XCTAssertEqual(assessments.count, 3)
        XCTAssertTrue(assessments.allSatisfy { !$0.reasons.isEmpty })
        XCTAssertTrue(assessments.allSatisfy { $0.score >= 0 && $0.score <= 100 })
        XCTAssertTrue(assessments.allSatisfy { $0.readiness == 100 - $0.score })
    }

    func testMissingCodesDriveHighRiskNextAction() {
        let assessment = ClaimRiskScorer.assess(
            ClaimRiskInput(
                summary: "",
                icdCodes: [],
                cptCodes: [],
                specialty: nil,
                codeSet: nil,
                icdReferences: [],
                cptReferences: []
            )
        )

        XCTAssertEqual(assessment.level, .high)
        XCTAssertEqual(assessment.score, 69)
        XCTAssertEqual(assessment.nextAction, "Add a de-identified encounter summary before coding review.")
    }
}
