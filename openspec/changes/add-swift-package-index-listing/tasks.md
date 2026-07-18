## 1. Prerequisite Verification

- [x] 1.1 Confirm the repository is public and MIT-licensed (`LICENSE.md` present)
- [x] 1.2 Confirm `Package.swift` declares `swift-tools-version` 5.0 or later
- [x] 1.3 Confirm the existing `swift-ci.yaml` tag job produces valid semver `vX.Y.Z` tags

## 2. CI Validation Gate

- [x] 2.1 Add a `swift package dump-package` step to `.github/workflows/swift-pr.yaml`
- [x] 2.2 Verify the new step passes on the current `Package.swift`
- [x] 2.3 Verify the new step fails the workflow if the manifest is broken (smoke test)

## 3. Submission

- [ ] 3.1 Confirm with the user before filing the public submission issue
- [ ] 3.2 File the "Add a Package" GitHub Issue against `SwiftPackageIndex/SwiftPackageIndex-Server`
- [ ] 3.3 Record the issue URL in this change's proposal for traceability
