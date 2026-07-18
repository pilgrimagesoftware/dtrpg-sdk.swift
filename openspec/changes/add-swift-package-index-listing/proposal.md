## Why

The Swift SDK is a public, MIT-licensed package that other Swift projects (including `dtrpg-app.swift`) could consume via Swift Package Manager, but it isn't discoverable through the Swift Package Index (SPI) yet. Getting it listed makes the package findable, gives it a documentation/build-status badge, and validates that the existing CI release pipeline actually produces what SPI needs.

## What Changes

- Verify and document that the existing CI/release pipeline already satisfies SPI's indexing prerequisites: public repo, valid `Package.swift`, Swift 5+, at least one semver-tagged release, and a package that resolves and builds cleanly.
- Add a CI validation step that runs `swift package dump-package` (and `swift package resolve`) as an explicit pre-submission gate, so a manifest regression is caught before it would cause an SPI indexing/build failure.
- Submit the package to Swift Package Index via its "Add a Package" GitHub Issue process against `SwiftPackageIndex/SwiftPackageIndex-Server` (not a `PackageList` pull request, which is no longer the submission path).

## Capabilities

### New Capabilities
- `swift-package-index-listing`: Defines the prerequisites and validation gate required for the Swift SDK to be listed and build successfully on the Swift Package Index.

### Modified Capabilities
(none — this change adds a new CI validation step and a one-time external submission; it does not alter any existing capability's requirements)

## Impact

- `dtrpg-sdk/swift`: Adds a package-manifest validation step to CI (`.github/workflows/swift-pr.yaml` and/or `swift-ci.yaml`).
- External: Files a GitHub Issue against `SwiftPackageIndex/SwiftPackageIndex-Server` to request indexing. This is a one-time, user-confirmed action since it is publicly visible on a third-party repository.
- No `.spi.yml` manifest is added — the package's single macOS library target should resolve correctly under SPI's default build-scheme detection, and no custom build/documentation configuration is currently needed.
