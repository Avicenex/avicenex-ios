# Avicenex AI iOS

Native SwiftUI MVP for Avicenex AI mobile workflows.

The repo was empty when scaffolded, so this project provides a runnable Xcode app target plus the native source module, demo review data, calculated claim risk scoring, and SwiftUI screens for:

- Pre-bill review queue
- Claim detail with calculated risk panel
- ICD-10-CM and CPT/HCPCS reference sections
- Workflow assistant entry points
- Full original web tool catalog: Chat, Coding Assistant, Pre-Bill Review, Code Lookup, Compare Codes, Cheat Sheet, Prior Auth Lookup, Denial Analyzer, Modifier Lookup, Appeal Letter, E/M Calculator, Batch Validator, CCI Edit Checker, CARC/RARC Lookup, Prior Auth Tracker, Claim Scrubber, Bookmarks, and Profiles
- Specialty/profile code sets

The bundled data is derived from the Avicenex web repo reference files and keeps the PHI/compliance reminder visible in the review workflow.

## Verify

```sh
swift test
swift run AvicenexAISmoke
```

## Run In Xcode

1. Install full Xcode from the Mac App Store or Apple Developer downloads.
2. Open `AvicenexAI.xcodeproj`.
3. Select the `AvicenexAI` scheme.
4. Choose an iPhone simulator.
5. Press Run.

The app target wraps `AvicenexAIAppView` and targets iOS 17.
