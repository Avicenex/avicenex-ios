import Foundation

@MainActor
public final class ReviewStore: ObservableObject {
    @Published public var claims: [ReviewClaim]
    @Published public var selectedClaimID: String

    public init(claims: [ReviewClaim] = AvicenexDemoData.claims) {
        self.claims = claims
        self.selectedClaimID = claims.first?.id ?? ""
    }

    public var selectedClaim: ReviewClaim {
        claims.first { $0.id == selectedClaimID } ?? claims[0]
    }

    public func assessment(for claim: ReviewClaim) -> ClaimRiskAssessment {
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
}
