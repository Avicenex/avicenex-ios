import Foundation

public enum AvicenexDemoData {
    public static let claims: [ReviewClaim] = [
        ReviewClaim(
            id: "CLM-1048",
            owner: "Billing",
            specialty: "Primary Care",
            encounter: "Established follow-up",
            summary: "Diabetes and hypertension follow-up with medication review, A1C ordered, and proposed level 4 E/M.",
            proposedIcd: ["E11.9", "I10"],
            proposedCpt: ["99214", "83036"],
            profileId: "primary-care-demo",
            status: "Needs documentation"
        ),
        ReviewClaim(
            id: "CLM-1051",
            owner: "MA queue",
            specialty: "Primary Care",
            encounter: "Medicare wellness",
            summary: "Annual wellness visit with problem-focused hypertension medication adjustment on the same date.",
            proposedIcd: ["Z00.00", "I10"],
            proposedCpt: ["G0439", "99213"],
            profileId: "primary-care-demo",
            status: "Needs coding review"
        ),
        ReviewClaim(
            id: "CLM-1056",
            owner: "Coding",
            specialty: "Endocrinology",
            encounter: "Diabetes complication review",
            summary: "Type 2 diabetes follow-up with neuropathy assessment and medication management.",
            proposedIcd: ["E11.40", "E11.42"],
            proposedCpt: ["99214"],
            profileId: "endocrinology-demo",
            status: "Payer check needed"
        )
    ]

    public static let codeSets: [CodeSet] = [
        CodeSet(
            id: "primary-care-demo",
            name: "Primary Care Demo Set",
            ownerType: "specialty",
            description: "Common ICD-10 references for primary care follow-up, wellness, and chronic condition documentation.",
            codes: ["E11.9", "E11.40", "E11.42", "I10", "J45.909", "M54.50", "Z00.00"]
        ),
        CodeSet(
            id: "endocrinology-demo",
            name: "Endocrinology Demo Set",
            ownerType: "specialty",
            description: "Common ICD-10 references for diabetes and endocrine-focused billing/coding conversations.",
            codes: ["E11.9", "E11.40", "E11.42"]
        ),
        CodeSet(
            id: "urgent-care-demo",
            name: "Urgent Care Demo Set",
            ownerType: "specialty",
            description: "Common ICD-10 references for urgent care style symptoms and episodic visits.",
            codes: ["J45.909", "M54.50", "R07.9", "I10"]
        )
    ]

    public static let icdCodes: [IcdCode] = [
        IcdCode(code: "E11.9", description: "Type 2 diabetes mellitus without complications", shortDescription: "Type 2 diabetes without complications", billable: true),
        IcdCode(code: "E11.40", description: "Type 2 diabetes mellitus with diabetic neuropathy, unspecified", shortDescription: "Type 2 diabetes with neuropathy", billable: true),
        IcdCode(code: "E11.42", description: "Type 2 diabetes mellitus with diabetic polyneuropathy", shortDescription: "Type 2 diabetes with diabetic polyneuropathy", billable: true),
        IcdCode(code: "I10", description: "Essential hypertension", shortDescription: "Essential hypertension", billable: true),
        IcdCode(code: "Z00.00", description: "Encounter for general adult medical examination without abnormal findings", shortDescription: "Adult medical exam without abnormal findings", billable: true),
        IcdCode(code: "J45.909", description: "Unspecified asthma, uncomplicated", shortDescription: "Unspecified asthma, uncomplicated", billable: true),
        IcdCode(code: "M54.50", description: "Low back pain, unspecified", shortDescription: "Low back pain", billable: true),
        IcdCode(code: "R07.9", description: "Chest pain, unspecified", shortDescription: "Chest pain", billable: true)
    ]

    public static let cptCodes: [CptHcpcsCode] = [
        CptHcpcsCode(
            code: "99214",
            codeSystem: "CPT",
            category: "Evaluation and Management",
            subCategory: "Office or outpatient visit",
            plainLanguageLabel: "Established patient office visit, moderate complexity",
            plainLanguageDescription: "Established patient evaluation and management visit commonly associated with moderate medical decision making or a longer time-based encounter.",
            clinicalArea: ["Primary Care", "Specialty Care", "Endocrinology", "Cardiology"],
            commonSettings: ["Office", "Outpatient clinic", "Telehealth when payer allows"],
            documentationPrompts: ["Problems addressed and status", "Medication management", "Data ordered or reviewed", "Risk of complications or management", "Total time when used"],
            modifierHints: ["25", "95"],
            riskFlags: ["Moderate risk or data must be documented when MDM supports the level.", "Payer downcoding risk increases when assessment and plan are thin."],
            keywords: ["established patient", "level 4 office visit", "moderate mdm", "chronic disease", "medication management", "99214"]
        ),
        CptHcpcsCode(
            code: "99213",
            codeSystem: "CPT",
            category: "Evaluation and Management",
            subCategory: "Office or outpatient visit",
            plainLanguageLabel: "Established patient office visit, low complexity",
            plainLanguageDescription: "Established patient evaluation and management visit commonly associated with low medical decision making or a moderate short time-based encounter.",
            clinicalArea: ["Primary Care", "Specialty Care", "Behavioral Health"],
            commonSettings: ["Office", "Outpatient clinic", "Telehealth when payer allows"],
            documentationPrompts: ["Established patient status", "Condition status", "Medication changes or management", "Tests ordered or reviewed", "Follow-up plan"],
            modifierHints: ["25", "95"],
            riskFlags: ["Support E/M level using MDM or time.", "Check telehealth modifier and place-of-service rules by payer."],
            keywords: ["established patient", "level 3 office visit", "follow-up", "low mdm", "medication refill", "e/m", "99213"]
        ),
        CptHcpcsCode(
            code: "83036",
            codeSystem: "CPT",
            category: "Pathology and Laboratory",
            subCategory: "Chemistry",
            plainLanguageLabel: "Hemoglobin A1C test",
            plainLanguageDescription: "Lab test commonly used to monitor average blood glucose control for diabetes care.",
            clinicalArea: ["Primary Care", "Endocrinology"],
            commonSettings: ["Office", "Outpatient lab"],
            documentationPrompts: ["Diabetes or glycemic monitoring indication", "Order linkage", "Result follow-up plan"],
            modifierHints: [],
            riskFlags: ["Confirm medical necessity and diagnosis support for payer policy."],
            keywords: ["a1c", "hemoglobin", "diabetes", "lab", "83036"]
        ),
        CptHcpcsCode(
            code: "G0439",
            codeSystem: "HCPCS",
            category: "Preventive / Medicare",
            subCategory: "Annual wellness visit",
            plainLanguageLabel: "Subsequent Medicare annual wellness visit",
            plainLanguageDescription: "Subsequent Medicare annual wellness visit workflow for eligible beneficiaries.",
            clinicalArea: ["Primary Care", "Geriatrics"],
            commonSettings: ["Office", "Outpatient clinic"],
            documentationPrompts: ["Eligibility timing", "Updated health risk assessment", "Updated prevention plan", "Cognitive and functional review when required", "Screening schedule"],
            modifierHints: ["25"],
            riskFlags: ["Confirm prior AWV timing.", "Problem-oriented E/M on the same day requires separately identifiable documentation."],
            keywords: ["annual wellness visit", "awv", "subsequent awv", "medicare wellness", "g0439"]
        )
    ]
}
