import Foundation

public enum ReviewRisk: String, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    public var id: String { rawValue }
}

public struct ReviewClaim: Identifiable, Equatable {
    public let id: String
    public let owner: String
    public let specialty: String
    public let encounter: String
    public let summary: String
    public let proposedIcd: [String]
    public let proposedCpt: [String]
    public let profileId: String
    public let status: String
}

public struct IcdCode: Equatable {
    public let code: String
    public let description: String
    public let shortDescription: String
    public let billable: Bool
}

public struct CodeSet: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let ownerType: String
    public let description: String
    public let codes: [String]
}

public struct CptHcpcsCode: Equatable {
    public let code: String
    public let codeSystem: String
    public let category: String
    public let subCategory: String
    public let plainLanguageLabel: String
    public let plainLanguageDescription: String
    public let clinicalArea: [String]
    public let commonSettings: [String]
    public let documentationPrompts: [String]
    public let modifierHints: [String]
    public let riskFlags: [String]
    public let keywords: [String]
}

public struct ClaimRiskReason: Identifiable, Equatable {
    public var id: String { "\(label)-\(points)-\(detail)" }
    public let label: String
    public let points: Int
    public let detail: String
}

public struct ClaimRiskAssessment: Equatable {
    public let score: Int
    public let readiness: Int
    public let level: ReviewRisk
    public let reasons: [ClaimRiskReason]
    public let nextAction: String
}
