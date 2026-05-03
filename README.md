# Avicenex AI iOS

Native SwiftUI MVP for Avicenex AI mobile workflows.

The repo was empty when scaffolded, so this package provides the native source module, demo review data, calculated claim risk scoring, and SwiftUI screens for:

- Pre-bill review queue
- Claim detail with calculated risk panel
- ICD-10-CM and CPT/HCPCS reference sections
- Workflow assistant entry points
- Specialty/profile code sets

The bundled data is derived from the Avicenex web repo reference files and keeps the PHI/compliance reminder visible in the review workflow.

## Verify

```sh
swift test
```

The module targets iOS 17 and is ready to be embedded in an Xcode app target as `AvicenexAIAppView`.
