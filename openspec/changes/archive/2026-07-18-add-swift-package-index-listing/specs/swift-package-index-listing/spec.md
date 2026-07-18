## ADDED Requirements

### Requirement: CI MUST validate that the package manifest resolves cleanly
The repository's CI MUST run a manifest-resolution check (`swift package dump-package`) on every pull request, so a broken or ambiguous `Package.swift` is caught before merge rather than surfacing later as a Swift Package Index build failure.

#### Scenario: Package manifest is valid
- **WHEN** CI runs the manifest-resolution check against a valid `Package.swift`
- **THEN** the check succeeds and CI proceeds to build and test

#### Scenario: Package manifest is broken
- **WHEN** CI runs the manifest-resolution check against a `Package.swift` that fails to resolve
- **THEN** the check fails and blocks the pull request from merging

### Requirement: The repository MUST satisfy Swift Package Index's indexing prerequisites
The repository MUST be public, MIT-licensed with a `LICENSE.md`, define a `Package.swift` with `swift-tools-version` 5.0 or later, and have at least one semver git tag produced by the existing release automation.

#### Scenario: Verifying indexing prerequisites
- **WHEN** the prerequisites are checked against the current repository state
- **THEN** the repository is public, has a valid `Package.swift`, and has at least one `vX.Y.Z` tag from the existing tag-on-push-to-develop workflow

### Requirement: The package MUST be submitted to Swift Package Index exactly once, with explicit confirmation
Submission to Swift Package Index MUST be performed via the "Add Package(s)" GitHub Issue template on `SwiftPackageIndex/PackageList`, and MUST NOT be filed without the user's explicit, in-conversation confirmation immediately beforehand, since it is a public action on a third-party repository.

#### Scenario: Submitting the package
- **WHEN** all indexing prerequisites and the manifest-validation CI check are confirmed passing
- **THEN** the "Add Package(s)" issue is filed against `SwiftPackageIndex/PackageList` referencing the repository's HTTPS `.git` URL, only after the user has explicitly confirmed the submission
