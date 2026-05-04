import AvicenexAI
import Foundation

func require(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() {
        fputs("Smoke check failed: \(message)\n", stderr)
        exit(1)
    }
}

let claims = AvicenexDemoData.claims
require(claims.count == 3, "expected bundled demo claims")

let assessments = claims.map { claim in
    ClaimRiskScorer.assess(
        ClaimRiskInput(
            summary: claim.summary,
            icdCodes: claim.proposedIcd,
            cptCodes: claim.proposedCpt,
            specialty: claim.specialty,
            codeSet: AvicenexDemoData.codeSets.first { $0.id == claim.profileId },
            icdReferences: claim.proposedIcd.compactMap { code in
                AvicenexDemoData.icdCodes.first { $0.code.caseInsensitiveCompare(code) == .orderedSame }
            },
            cptReferences: claim.proposedCpt.compactMap { code in
                AvicenexDemoData.cptCodes.first { $0.code.caseInsensitiveCompare(code) == .orderedSame }
            }
        )
    )
}

require(assessments.allSatisfy { !$0.reasons.isEmpty }, "each claim should have explainable risk reasons")
require(assessments.allSatisfy { $0.score >= 0 && $0.score <= 100 }, "risk score should stay in 0...100")
require(assessments.allSatisfy { $0.readiness == 100 - $0.score }, "readiness should mirror risk score")

let toolIds = Set(AvicenexToolCatalog.tools.map(\.id))
[
    "chat", "assistant", "review", "lookup", "compare", "cheatsheet", "prior-auth", "denial",
    "modifiers", "appeal", "em-calculator", "batch-validate", "cci-check", "carc-rarc",
    "pa-tracker", "claim-scrubber", "bookmarks", "profiles"
].forEach { id in
    require(toolIds.contains(id), "missing tool \(id)")
}

print("AvicenexAISmoke passed: \(claims.count) claims, \(AvicenexToolCatalog.tools.count) tools")
