import SwiftUI

public struct AvicenexAIAppView: View {
    @StateObject private var store = ReviewStore()
    @State private var tab = WorkflowTab.review

    public init() {}

    public var body: some View {
        TabView(selection: $tab) {
            NavigationSplitView {
                ClaimQueueView(store: store)
            } detail: {
                ClaimDetailView(store: store, claim: store.selectedClaim)
            }
            .tabItem { Label("Review", systemImage: "checklist.checked") }
            .tag(WorkflowTab.review)

            AssistantWorkflowView()
                .tabItem { Label("Assistant", systemImage: "sparkles") }
                .tag(WorkflowTab.assistant)

            ToolsCatalogView()
                .tabItem { Label("Tools", systemImage: "square.grid.2x2") }
                .tag(WorkflowTab.tools)

            ReferencesView()
                .tabItem { Label("Profiles", systemImage: "books.vertical") }
                .tag(WorkflowTab.references)
        }
        .tint(.teal)
    }
}

private enum WorkflowTab {
    case review
    case assistant
    case tools
    case references
}

private struct ClaimQueueView: View {
    @ObservedObject var store: ReviewStore

    var body: some View {
        List(selection: $store.selectedClaimID) {
            Section("Pre-bill queue") {
                ForEach(store.claims) { claim in
                    let assessment = store.assessment(for: claim)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(claim.id)
                                .font(.headline)
                            Spacer()
                            RiskBadge(level: assessment.level)
                        }
                        Text(claim.summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                        HStack {
                            Text(claim.owner)
                            Text(claim.status)
                            Spacer()
                            Text("\(assessment.readiness)% ready")
                                .monospacedDigit()
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .tag(claim.id)
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("Avicenex AI")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Review")
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}

private struct ClaimDetailView: View {
    @ObservedObject var store: ReviewStore
    let claim: ReviewClaim

    var body: some View {
        let assessment = store.assessment(for: claim)

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ComplianceBanner()
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(claim.id)
                                .font(.title2.weight(.semibold))
                            Text("\(claim.specialty) - \(claim.encounter)")
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        RiskBadge(level: assessment.level)
                    }
                    Text(claim.summary)
                        .font(.body)
                    Text("Next action: \(assessment.nextAction)")
                        .font(.callout.weight(.medium))
                }

                RiskPanel(assessment: assessment)

                TwoColumnReferenceSection(title: "ICD-10-CM", values: claim.proposedIcd, references: claim.proposedIcd.compactMap { code in
                    AvicenexDemoData.icdCodes.first { $0.code == code }.map { "\($0.code) - \($0.shortDescription)" }
                })

                TwoColumnReferenceSection(title: "CPT/HCPCS", values: claim.proposedCpt, references: claim.proposedCpt.compactMap { code in
                    AvicenexDemoData.cptCodes.first { $0.code == code }.map { "\($0.code) - \($0.plainLanguageLabel)" }
                })
            }
            .padding()
        }
        .navigationTitle("Claim detail")
    }
}

private struct RiskPanel: View {
    let assessment: ClaimRiskAssessment

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Calculated risk")
                    .font(.headline)
                Spacer()
                Text("\(assessment.score)")
                    .font(.largeTitle.weight(.bold))
                    .monospacedDigit()
            }
            ProgressView(value: Double(assessment.readiness), total: 100)
                .tint(.teal)
            Text("\(assessment.readiness)% readiness")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(assessment.reasons.prefix(5)) { reason in
                HStack(alignment: .top, spacing: 10) {
                    Text("+\(reason.points)")
                        .font(.caption.weight(.bold))
                        .monospacedDigit()
                        .frame(width: 44, alignment: .leading)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(reason.label)
                            .font(.subheadline.weight(.semibold))
                        Text(reason.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Divider()
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct ComplianceBanner: View {
    var body: some View {
        Label("Use de-identified claim summaries only. Avicenex AI supports pre-bill QA and does not replace official coding, payer, NCCI, LCD/NCD, or compliance review.", systemImage: "shield.lefthalf.filled")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(12)
            .background(Color.teal.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct TwoColumnReferenceSection: View {
    let title: String
    let values: [String]
    let references: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 8) {
                ForEach(values, id: \.self) { value in
                    Text(value)
                        .font(.callout.weight(.semibold))
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            ForEach(references, id: \.self) { reference in
                Text(reference)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct AssistantWorkflowView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Workflow assistant") {
                    ForEach(AvicenexToolCatalog.tools(in: .aiWorkspace)) { tool in
                        NavigationLink {
                            ToolDetailView(tool: tool)
                        } label: {
                            Label(tool.title, systemImage: tool.systemImage)
                        }
                    }
                }
                Section("Reminder") {
                    Text("Avicenex AI should be used with de-identified content and local policy review.")
                }
            }
            .navigationTitle("Assistant")
        }
    }
}

private struct ToolsCatalogView: View {
    @State private var query = ""

    private var filteredGroups: [(AvicenexToolGroup, [AvicenexTool])] {
        AvicenexToolGroup.allCases.compactMap { group in
            let groupTools = AvicenexToolCatalog.tools(in: group).filter { tool in
                query.isEmpty ||
                tool.title.localizedCaseInsensitiveContains(query) ||
                tool.summary.localizedCaseInsensitiveContains(query) ||
                tool.webRoute.localizedCaseInsensitiveContains(query)
            }
            return groupTools.isEmpty ? nil : (group, groupTools)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ComplianceBanner()
                    Text("Native MVP entry points for the full Avicenex web toolset. Offline tools use bundled local references; AI tools are ready for backend wiring.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                ForEach(filteredGroups, id: \.0.id) { group, tools in
                    Section(group.rawValue) {
                        ForEach(tools) { tool in
                            NavigationLink {
                                ToolDetailView(tool: tool)
                            } label: {
                                ToolRow(tool: tool)
                            }
                        }
                    }
                }
            }
            .searchable(text: $query, prompt: "Search tools")
            .navigationTitle("Tools")
        }
    }
}

private struct ToolRow: View {
    let tool: AvicenexTool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: tool.systemImage)
                .frame(width: 28)
                .foregroundStyle(.teal)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(tool.title)
                        .font(.headline)
                    Spacer()
                    if tool.requiresAI {
                        Text("AI")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.purple)
                    }
                    if tool.offlineCapable {
                        Text("Offline")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.teal)
                    }
                }
                Text(tool.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                Text(tool.webRoute)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct ToolDetailView: View {
    let tool: AvicenexTool

    var body: some View {
        List {
            Section {
                Label(tool.title, systemImage: tool.systemImage)
                    .font(.title3.weight(.semibold))
                Text(tool.summary)
                    .foregroundStyle(.secondary)
                HStack {
                    ToolPill(text: tool.webRoute)
                    if tool.requiresAI { ToolPill(text: "AI-backed") }
                    if tool.offlineCapable { ToolPill(text: "Offline-ready") }
                }
            }

            Section("Native workflow") {
                Text(tool.nativeWorkflow)
                if tool.requiresAI {
                    Text("Backend/API connection required for live AI output. Keep PHI out of prompts and verify all coding guidance against official sources and payer policy.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Example inputs") {
                ForEach(tool.exampleInputs, id: \.self) { input in
                    Text(input)
                }
            }

            Section("Expected output") {
                ForEach(tool.expectedOutput, id: \.self) { output in
                    Label(output, systemImage: "checkmark.circle")
                }
            }

            ToolReferencePreview(tool: tool)
        }
        .navigationTitle(tool.title)
    }
}

private struct ToolPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.teal.opacity(0.1))
            .clipShape(Capsule())
    }
}

private struct ToolReferencePreview: View {
    let tool: AvicenexTool

    var body: some View {
        switch tool.id {
        case "lookup", "batch-validate", "bookmarks":
            Section("Local reference sample") {
                ForEach(AvicenexDemoData.icdCodes.prefix(3), id: \.code) { code in
                    Text("\(code.code) - \(code.shortDescription)")
                }
                ForEach(AvicenexDemoData.cptCodes.prefix(3), id: \.code) { code in
                    Text("\(code.code) - \(code.plainLanguageLabel)")
                }
            }
        case "em-calculator":
            Section("Sample recommendation") {
                Text("Established patient + moderate MDM -> 99214 when supported by documentation.")
                Text("Total time should be checked against current CMS thresholds and payer policy.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        case "claim-scrubber":
            Section("Sample scrub checks") {
                Text("Diagnosis present, CPT present, diagnosis pointer present")
                Text("Watch for E/M + procedure without modifier -25 and CCI edits.")
            }
        case "pa-tracker":
            Section("Sample tracker columns") {
                Text("Status, urgency, payer, CPT/HCPCS, submitted date, auth number, expiration")
            }
        default:
            EmptyView()
        }
    }
}

private struct ReferencesView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(AvicenexDemoData.codeSets) { codeSet in
                    Section(codeSet.name) {
                        Text(codeSet.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(codeSet.codes.joined(separator: ", "))
                            .font(.callout.monospaced())
                    }
                }
            }
            .navigationTitle("Profiles")
        }
    }
}

private struct RiskBadge: View {
    let level: ReviewRisk

    var body: some View {
        Text(level.rawValue)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(color)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private var color: Color {
        switch level {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}
