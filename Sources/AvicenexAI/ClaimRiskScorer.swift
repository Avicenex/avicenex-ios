import Foundation

public struct ClaimRiskInput {
    public let summary: String
    public let icdCodes: [String]
    public let cptCodes: [String]
    public let specialty: String?
    public let codeSet: CodeSet?
    public let icdReferences: [IcdCode]
    public let cptReferences: [CptHcpcsCode]

    public init(summary: String, icdCodes: [String], cptCodes: [String], specialty: String?, codeSet: CodeSet?, icdReferences: [IcdCode], cptReferences: [CptHcpcsCode]) {
        self.summary = summary
        self.icdCodes = icdCodes
        self.cptCodes = cptCodes
        self.specialty = specialty
        self.codeSet = codeSet
        self.icdReferences = icdReferences
        self.cptReferences = cptReferences
    }
}

public enum ClaimRiskScorer {
    private static let maxDocumentationPromptPoints = 18
    private static let maxModifierHintPoints = 12
    private static let maxRiskFlagPoints = 24

    public static func assess(_ input: ClaimRiskInput) -> ClaimRiskAssessment {
        let summary = input.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        let icdCodes = unique(input.icdCodes.map { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() })
        let cptCodes = unique(input.cptCodes.map { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() })
        var reasons: [ClaimRiskReason] = []

        if summary.isEmpty {
            push(&reasons, "Missing claim summary", 25, "No de-identified encounter summary is available to support the proposed codes.")
        } else if summary.count < 50 {
            push(&reasons, "Thin claim summary", 8, "The summary is brief; confirm it captures the key diagnoses, services, orders, and plan.")
        }

        if icdCodes.isEmpty {
            push(&reasons, "Missing ICD-10-CM codes", 22, "No proposed diagnosis codes were entered.")
        }

        if cptCodes.isEmpty {
            push(&reasons, "Missing CPT/HCPCS codes", 22, "No proposed service, procedure, or supply codes were entered.")
        }

        let unknownIcdCodes = unknownCodes(icdCodes, knownCodes: input.icdReferences.map(\.code))
        push(&reasons, "Unknown local ICD-10-CM code", min(24, unknownIcdCodes.count * 12), unknownIcdCodes.isEmpty ? "" : "\(unknownIcdCodes.joined(separator: ", ")) did not match the local ICD-10-CM reference.")

        let nonBillableCodes = input.icdReferences.filter { !$0.billable }
        push(&reasons, "Non-billable ICD-10-CM code", min(24, nonBillableCodes.count * 18), nonBillableCodes.isEmpty ? "" : "\(nonBillableCodes.map(\.code).joined(separator: ", ")) is marked as a header/non-billable diagnosis.")

        let unknownCptCodes = unknownCodes(cptCodes, knownCodes: input.cptReferences.map(\.code))
        push(&reasons, "Unknown local CPT/HCPCS code", min(24, unknownCptCodes.count * 12), unknownCptCodes.isEmpty ? "" : "\(unknownCptCodes.joined(separator: ", ")) did not match the local CPT/HCPCS reference layer.")

        let riskFlagCount = input.cptReferences.reduce(0) { $0 + $1.riskFlags.count }
        push(&reasons, "CPT/HCPCS risk flags", min(maxRiskFlagPoints, riskFlagCount * 4), riskFlagCount == 0 ? "" : "\(riskFlagCount) curated risk flag\(riskFlagCount == 1 ? "" : "s") require review across the proposed CPT/HCPCS codes.")

        let modifierHintCount = input.cptReferences.reduce(0) { $0 + $1.modifierHints.count }
        push(&reasons, "Modifier verification", min(maxModifierHintPoints, modifierHintCount * 3), modifierHintCount == 0 ? "" : "\(modifierHintCount) modifier hint\(modifierHintCount == 1 ? "" : "s") should be verified for payer and encounter fit.")

        let documentationPromptCount = input.cptReferences.reduce(0) { $0 + $1.documentationPrompts.count }
        push(&reasons, "Documentation support", min(maxDocumentationPromptPoints, documentationPromptCount * 2), documentationPromptCount == 0 ? "" : "\(documentationPromptCount) documentation prompt\(documentationPromptCount == 1 ? "" : "s") should be supported in the chart.")

        let payerFlagCount = input.cptReferences.reduce(0) { total, code in
            total + (code.riskFlags + code.documentationPrompts + code.modifierHints).filter {
                hasAnyTerm($0, ["payer", "medicare", "coverage", "eligibility", "bundling", "threshold"])
            }.count
        }
        push(&reasons, "Payer/manual verification", min(12, payerFlagCount * 3), payerFlagCount == 0 ? "" : "\(payerFlagCount) item\(payerFlagCount == 1 ? "" : "s") mention payer, Medicare, coverage, eligibility, bundling, or thresholds.")

        if let codeSet = input.codeSet, !icdCodes.isEmpty {
            let profileCodes = Set(codeSet.codes.map { $0.uppercased() })
            let outsideProfileCodes = icdCodes.filter { !profileCodes.contains($0) }
            push(&reasons, "Profile context check", min(10, outsideProfileCodes.count * 5), outsideProfileCodes.isEmpty ? "" : "\(outsideProfileCodes.joined(separator: ", ")) is outside the selected \(codeSet.name).")
        }

        if let mismatch = procedureDiagnosisMismatch(cptReferences: input.cptReferences, icdReferences: input.icdReferences, summary: summary) {
            push(&reasons, "Procedure and diagnosis context", mismatch.points, mismatch.detail)
        }

        if let mismatch = specialtyContextMismatch(cptReferences: input.cptReferences, specialty: input.specialty, codeSet: input.codeSet) {
            push(&reasons, "Specialty context check", mismatch.points, mismatch.detail)
        }

        let sortedReasons = reasons
            .filter { !$0.detail.isEmpty }
            .sorted { $0.points == $1.points ? $0.label < $1.label : $0.points > $1.points }
        let score = min(100, sortedReasons.reduce(0) { $0 + $1.points })
        let level = riskLevel(score)

        return ClaimRiskAssessment(score: score, readiness: max(0, 100 - score), level: level, reasons: sortedReasons, nextAction: nextAction(for: sortedReasons, level: level))
    }

    private static func normalize(_ value: String) -> String {
        value.lowercased().replacingOccurrences(of: "[^a-z0-9]+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func unique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { !$0.isEmpty && seen.insert($0).inserted }
    }

    private static func hasAnyTerm(_ value: String, _ terms: [String]) -> Bool {
        let normalized = normalize(value)
        return terms.contains { normalized.contains($0) }
    }

    private static func riskLevel(_ score: Int) -> ReviewRisk {
        if score >= 60 { return .high }
        if score >= 30 { return .medium }
        return .low
    }

    private static func push(_ reasons: inout [ClaimRiskReason], _ label: String, _ points: Int, _ detail: String) {
        guard points > 0 else { return }
        reasons.append(ClaimRiskReason(label: label, points: points, detail: detail))
    }

    private static func unknownCodes(_ codes: [String], knownCodes: [String]) -> [String] {
        let known = Set(knownCodes.map { $0.uppercased() })
        return codes.filter { !known.contains($0.uppercased()) }
    }

    private static func procedureDiagnosisMismatch(cptReferences: [CptHcpcsCode], icdReferences: [IcdCode], summary: String) -> (points: Int, detail: String)? {
        let diagnosisContext = "\(summary) \(icdReferences.map { "\($0.code) \($0.description) \($0.shortDescription)" }.joined(separator: " "))"
        let preventiveCode = icdReferences.contains { $0.code.hasPrefix("Z00") }
        let diabetesContext = hasAnyTerm(diagnosisContext, ["diabetes", "a1c", "hemoglobin"])

        for code in cptReferences {
            let procedureContext = normalize("\(code.category) \(code.subCategory) \(code.plainLanguageLabel) \(code.plainLanguageDescription) \(code.keywords.joined(separator: " "))")
            if (procedureContext.contains("annual wellness") || procedureContext.contains("preventive")) && !preventiveCode {
                return (10, "\(code.code) appears preventive/wellness-oriented, but the ICD list does not include an obvious preventive diagnosis such as Z00.00.")
            }
            if (procedureContext.contains("a1c") || procedureContext.contains("hemoglobin")) && !diabetesContext {
                return (10, "\(code.code) appears diabetes/A1C-related, but the summary and ICD context do not show clear diabetes support.")
            }
        }
        return nil
    }

    private static func specialtyContextMismatch(cptReferences: [CptHcpcsCode], specialty: String?, codeSet: CodeSet?) -> (points: Int, detail: String)? {
        let context = normalize("\(specialty ?? "") \(codeSet?.name ?? "") \(codeSet?.description ?? "")")
        guard !context.isEmpty else { return nil }
        let mismatches = cptReferences.filter { code in
            if code.clinicalArea.contains(where: { normalize($0).contains("specialty care") }) {
                return false
            }
            return !code.clinicalArea.contains { area in
                normalize(area).split(separator: " ").filter { $0.count > 3 }.contains { context.contains($0) }
            }
        }
        guard !mismatches.isEmpty else { return nil }
        return (min(8, mismatches.count * 4), "\(mismatches.map(\.code).joined(separator: ", ")) should be checked against the selected specialty/profile context.")
    }

    private static func nextAction(for reasons: [ClaimRiskReason], level: ReviewRisk) -> String {
        guard let topReason = reasons.first else {
            return "Proceed with standard pre-bill QA and payer policy checks."
        }
        switch topReason.label {
        case "Missing claim summary":
            return "Add a de-identified encounter summary before coding review."
        case "Missing ICD-10-CM codes":
            return "Add supported ICD-10-CM diagnosis codes from the chart."
        case "Missing CPT/HCPCS codes":
            return "Add proposed CPT/HCPCS service codes before submission review."
        case "Non-billable ICD-10-CM code":
            return "Replace header/non-billable ICD-10-CM entries with billable supported codes."
        case let label where label.contains("Unknown"):
            return "Verify unmatched codes against the current ICD-10-CM, CPT/HCPCS, and payer references."
        case "CPT/HCPCS risk flags":
            return "Resolve the highest-impact CPT/HCPCS risk flags before billing."
        case "Modifier verification":
            return "Confirm modifier use and payer-specific requirements."
        case "Documentation support":
            return "Confirm the chart supports the listed documentation prompts."
        default:
            if level == .high { return "Hold for coding review before claim submission." }
            if level == .medium { return "Route for targeted documentation or payer verification." }
            return "Proceed with standard pre-bill QA and payer policy checks."
        }
    }
}
