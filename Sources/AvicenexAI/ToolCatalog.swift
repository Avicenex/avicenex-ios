import Foundation

public enum AvicenexToolGroup: String, CaseIterable, Identifiable {
    case aiWorkspace = "AI Workspace"
    case billingCoding = "Billing & Coding"
    case validatorsLookup = "Validators & Lookup"
    case claimManagement = "Claim & Denial Management"
    case personalization = "Personalization"

    public var id: String { rawValue }
}

public struct AvicenexTool: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let webRoute: String
    public let group: AvicenexToolGroup
    public let summary: String
    public let nativeWorkflow: String
    public let requiresAI: Bool
    public let offlineCapable: Bool
    public let systemImage: String
    public let exampleInputs: [String]
    public let expectedOutput: [String]
}

public enum AvicenexToolCatalog {
    public static let tools: [AvicenexTool] = [
        AvicenexTool(
            id: "chat",
            title: "Chat",
            webRoute: "/chat",
            group: .aiWorkspace,
            summary: "Classic Avicenex AI medical billing and coding chat with specialty context, history, PHI reminders, markdown output, and export.",
            nativeWorkflow: "Mobile chat surface with saved sessions, de-identified prompt warning, specialty-aware system context, and export/share action.",
            requiresAI: true,
            offlineCapable: false,
            systemImage: "bubble.left.and.bubble.right",
            exampleInputs: ["Can you explain CPT 99214 documentation risk?", "Review a de-identified coding question."],
            expectedOutput: ["Streaming answer when API is available", "Mock/local guidance when offline backend is not configured"]
        ),
        AvicenexTool(
            id: "assistant",
            title: "Coding Assistant",
            webRoute: "/assistant",
            group: .aiWorkspace,
            summary: "Structured encounter workspace with notes input, AI ICD/CPT suggestions, rationale, CCI awareness, and a code basket.",
            nativeWorkflow: "Three-step native flow: encounter notes, suggested codes, confirmed code basket.",
            requiresAI: true,
            offlineCapable: false,
            systemImage: "sparkles",
            exampleInputs: ["Chief complaint, assessment, plan", "Procedures performed"],
            expectedOutput: ["Suggested ICD-10-CM and CPT/HCPCS codes", "Rationale and bundling warnings"]
        ),
        AvicenexTool(
            id: "review",
            title: "Pre-Bill Review",
            webRoute: "/review",
            group: .aiWorkspace,
            summary: "Claim queue workbench with calculated risk, readiness, reference payloads, and recommended next actions.",
            nativeWorkflow: "Implemented as the Review tab with queue, claim detail, calculated risk panel, ICD/CPT references, and compliance reminder.",
            requiresAI: true,
            offlineCapable: true,
            systemImage: "checklist.checked",
            exampleInputs: AvicenexDemoData.claims.map { "\($0.id): \($0.proposedIcd.joined(separator: ", ")) / \($0.proposedCpt.joined(separator: ", "))" },
            expectedOutput: ["Risk score 0-100", "Readiness", "Top risk reasons", "Next action"]
        ),
        AvicenexTool(
            id: "lookup",
            title: "Code Lookup",
            webRoute: "/lookup",
            group: .billingCoding,
            summary: "Search ICD-10-CM, CPT, and HCPCS by code or description with bookmark support.",
            nativeWorkflow: "Native searchable reference list backed by bundled demo ICD/CPT data until full data import is wired.",
            requiresAI: false,
            offlineCapable: true,
            systemImage: "magnifyingglass",
            exampleInputs: ["E11.9", "99214", "A1C"],
            expectedOutput: ["Code description", "Plain-language guidance", "Bookmark action"]
        ),
        AvicenexTool(
            id: "compare",
            title: "Compare Codes",
            webRoute: "/compare",
            group: .billingCoding,
            summary: "Side-by-side ICD/CPT comparison with descriptions, category, notes, and CCI relationship hints.",
            nativeWorkflow: "Two-code comparison using local reference objects and CCI note placeholders.",
            requiresAI: false,
            offlineCapable: true,
            systemImage: "rectangle.split.2x1",
            exampleInputs: ["99213 vs 99214", "E11.40 vs E11.42"],
            expectedOutput: ["Differences", "Billing behavior notes", "Bundling indicator when known"]
        ),
        AvicenexTool(
            id: "cheatsheet",
            title: "Cheat Sheet",
            webRoute: "/cheatsheet",
            group: .billingCoding,
            summary: "Payer and specialty reference card with common diagnoses, procedures, modifiers, and payer reminders.",
            nativeWorkflow: "Specialty profile card generated from bundled profile code sets and CPT references.",
            requiresAI: false,
            offlineCapable: true,
            systemImage: "doc.plaintext",
            exampleInputs: ["Primary Care + Medicare", "Endocrinology + Commercial"],
            expectedOutput: ["Top codes", "Modifier reminders", "Payer checks"]
        ),
        AvicenexTool(
            id: "prior-auth",
            title: "Prior Auth Lookup",
            webRoute: "/prior-auth",
            group: .billingCoding,
            summary: "CPT/HCPCS prior authorization requirement lookup by payer type with documentation and denial reminders.",
            nativeWorkflow: "Local guidance card for selected CPT/HCPCS code and payer type.",
            requiresAI: false,
            offlineCapable: true,
            systemImage: "shield",
            exampleInputs: ["G0439 Medicare", "99214 Commercial"],
            expectedOutput: ["Auth likelihood", "Required documents", "Common denial reasons"]
        ),
        AvicenexTool(
            id: "denial",
            title: "Denial Analyzer",
            webRoute: "/denial",
            group: .billingCoding,
            summary: "Explains denial codes/descriptions and suggests correction, resubmission, and appeal strategy.",
            nativeWorkflow: "Mobile denial intake with local CARC/RARC examples and AI handoff when configured.",
            requiresAI: true,
            offlineCapable: true,
            systemImage: "xmark.octagon",
            exampleInputs: ["CO-16", "N180", "Prior authorization absent"],
            expectedOutput: ["Meaning", "Likely causes", "Fix steps", "Appeal path"]
        ),
        AvicenexTool(
            id: "modifiers",
            title: "Modifier Lookup",
            webRoute: "/modifiers",
            group: .billingCoding,
            summary: "CPT/HCPCS modifier guide with use cases, payment impact, stacking rules, and documentation flags.",
            nativeWorkflow: "Searchable mobile modifier reference with payer-policy reminder.",
            requiresAI: false,
            offlineCapable: true,
            systemImage: "tag",
            exampleInputs: ["25", "59", "95"],
            expectedOutput: ["When to use", "Documentation needed", "Stacking cautions"]
        ),
        AvicenexTool(
            id: "em-calculator",
            title: "E/M Calculator",
            webRoute: "/em-calculator",
            group: .billingCoding,
            summary: "Office/outpatient E/M level calculator using MDM or time thresholds.",
            nativeWorkflow: "Native MDM/time selection flow returning 99202-99215 recommendation.",
            requiresAI: false,
            offlineCapable: true,
            systemImage: "function",
            exampleInputs: ["Moderate MDM, established patient", "45 minutes, new patient"],
            expectedOutput: ["Recommended E/M code", "Level explanation"]
        ),
        AvicenexTool(
            id: "batch-validate",
            title: "Batch Validator",
            webRoute: "/batch-validate",
            group: .validatorsLookup,
            summary: "Validate up to 200 pasted ICD/CPT/HCPCS codes and export results.",
            nativeWorkflow: "Paste codes, validate against bundled local references, then share CSV-style results.",
            requiresAI: false,
            offlineCapable: true,
            systemImage: "square.stack.3d.up",
            exampleInputs: ["E11.9, I10, 99214, 83036"],
            expectedOutput: ["Valid", "Invalid format", "Unrecognized"]
        ),
        AvicenexTool(
            id: "cci-check",
            title: "CCI Edit Checker",
            webRoute: "/cci-check",
            group: .validatorsLookup,
            summary: "Checks NCCI bundling edits between two procedure codes and modifier bypass rules.",
            nativeWorkflow: "Two CPT/HCPCS inputs with indicator explanation and modifier guidance.",
            requiresAI: false,
            offlineCapable: true,
            systemImage: "link.badge.plus",
            exampleInputs: ["E/M + procedure", "Column 1 / Column 2 CPT pair"],
            expectedOutput: ["Indicator 0/1/no known edit", "Bypass modifier guidance"]
        ),
        AvicenexTool(
            id: "carc-rarc",
            title: "CARC / RARC Lookup",
            webRoute: "/carc-rarc",
            group: .validatorsLookup,
            summary: "EOB/ERA reason and remark code lookup with category and next-step guidance.",
            nativeWorkflow: "Search remittance code cards with denial workflow handoff.",
            requiresAI: false,
            offlineCapable: true,
            systemImage: "doc.text.magnifyingglass",
            exampleInputs: ["CO-16", "N180", "MA01"],
            expectedOutput: ["Meaning", "Category", "Actionable next step"]
        ),
        AvicenexTool(
            id: "claim-scrubber",
            title: "Claim Scrubber",
            webRoute: "/claim-scrubber",
            group: .validatorsLookup,
            summary: "Client-side pre-submission validation for POS, diagnosis, CPT, modifiers, units, pointers, CCI edits, duplicates, and laterality.",
            nativeWorkflow: "Mobile claim form with offline scrub summary and issue list.",
            requiresAI: false,
            offlineCapable: true,
            systemImage: "wand.and.stars.inverse",
            exampleInputs: ["Clean claim", "E/M + procedure missing -25", "Wrong POS"],
            expectedOutput: ["Errors", "Warnings", "Resolution hints"]
        ),
        AvicenexTool(
            id: "appeal",
            title: "Appeal Letter",
            webRoute: "/appeal",
            group: .claimManagement,
            summary: "AI appeal letter generator for denied claims with documentation checklist.",
            nativeWorkflow: "Claim denial intake form with generated letter output when API is configured.",
            requiresAI: true,
            offlineCapable: false,
            systemImage: "square.and.pencil",
            exampleInputs: ["Claim number", "DOS", "CPT/ICD codes", "Payer", "Denial reason", "Medical necessity"],
            expectedOutput: ["Appeal letter", "Attachment checklist", "Copy/share"]
        ),
        AvicenexTool(
            id: "pa-tracker",
            title: "Prior Auth Tracker",
            webRoute: "/pa-tracker",
            group: .claimManagement,
            summary: "Local prior authorization request management with status filters, urgency, auth number, expiration, and notes.",
            nativeWorkflow: "Native list/detail tracker backed by device storage in a production app.",
            requiresAI: false,
            offlineCapable: true,
            systemImage: "calendar.badge.clock",
            exampleInputs: ["Pending urgent G0439 request", "Approved auth expiring in 7 days"],
            expectedOutput: ["Status board", "Expiration alert", "Search/filter"]
        ),
        AvicenexTool(
            id: "bookmarks",
            title: "Bookmarks",
            webRoute: "/bookmarks",
            group: .personalization,
            summary: "Saved ICD/CPT/HCPCS codes from lookup and workflow references.",
            nativeWorkflow: "Saved-code list for frequently used references.",
            requiresAI: false,
            offlineCapable: true,
            systemImage: "bookmark",
            exampleInputs: ["E11.9", "99214", "G0439"],
            expectedOutput: ["Saved references", "Quick access"]
        ),
        AvicenexTool(
            id: "profiles",
            title: "Specialty Profiles",
            webRoute: "/profiles",
            group: .personalization,
            summary: "Specialty/provider code set context that steers AI prompts and code lookup priority.",
            nativeWorkflow: "Implemented as Profiles tab with bundled specialty code sets.",
            requiresAI: false,
            offlineCapable: true,
            systemImage: "person.text.rectangle",
            exampleInputs: AvicenexDemoData.codeSets.map(\.name),
            expectedOutput: ["Selected specialty", "Favorite codes", "Prompt context"]
        )
    ]

    public static func tools(in group: AvicenexToolGroup) -> [AvicenexTool] {
        tools.filter { $0.group == group }
    }
}
