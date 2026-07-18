## Context

Swift Package Index (SPI) indexes public Swift packages and builds them independently once submitted — it does not poll or subscribe to a package's own CI. Indexing requires: a public repository, a valid `Package.swift`, Swift 5.0+, at least one semver git tag, and a package that resolves and compiles. Submission is a GitHub Issue against `SwiftPackageIndex/PackageList` using its "Add Package(s)" issue template (`labels: ['Add Package']`), confirmed directly from that repository's own template and README — not a pull request, and not against `SwiftPackageIndex-Server`.

The `dtrpg-sdk.swift` repository already satisfies every prerequisite:
- Public GitHub repo (`pilgrimagesoftware/dtrpg-sdk.swift`).
- `Package.swift` with `// swift-tools-version: 6.2`, a single `DriveThruRPGSDK` library product.
- `LICENSE.md` (MIT) and a `README.md`.
- `.github/workflows/swift-ci.yaml` already tags every push to `develop` with a semver `vX.Y.Z` tag via `anothrNick/github-tag-action` (`DEFAULT_BUMP: patch`), and builds/tests before tagging.

## Goals / Non-Goals

**Goals:**
- Add an explicit, fast-failing CI check that the package manifest resolves cleanly (`swift package dump-package`), so a manifest-level regression is caught in PR/CI rather than surfacing later as an SPI build failure.
- File the one-time "Add Package(s)" submission once CI confirms the prerequisites hold.

**Non-Goals:**
- Adding a `.spi.yml` manifest. SPI's default Xcode scheme/platform detection is expected to work for a single-target macOS library with no unusual build requirements; a custom manifest is only justified if SPI's build actually fails to auto-detect the scheme after submission.
- Building a multi-platform (iOS/tvOS/watchOS/Linux) CI matrix. The package's declared platform is `.macOS(.v15)` only; broadening platform support is a separate, unrelated decision.
- Any change to the existing tag/release automation — it already produces what SPI needs.

## Decisions

### Add a `swift package dump-package` step to the existing PR workflow, not a new workflow
Rationale: `.github/workflows/swift-pr.yaml` already builds and tests on every PR to `develop`. Manifest validation is cheap (sub-second) and belongs alongside the existing build/test steps rather than as a separate workflow file, keeping the "one thing breaks, one place to look" property.

### Do not add `.spi.yml` preemptively
Rationale: SPI's builder documentation states custom manifests are only needed when default scheme-detection heuristics fail (ambiguous multi-scheme repos, custom Docker images, non-standard platforms, or documentation-target selection). This package has exactly one library target and one obvious scheme; adding speculative configuration would be unverified guesswork with nothing to validate it against until after the package is actually indexed.

### Submit via the PackageList "Add Package(s)" GitHub Issue template, not a PackageList PR
Rationale: `SwiftPackageIndex/PackageList`'s own README and `.github/ISSUE_TEMPLATE/add_package.yml` confirm this is the current, maintainer-endorsed submission path — a structured issue listing the repository URL, not a pull request editing the package list JSON directly.

### Treat submission as a manual, confirmed action rather than an automated CI step
Rationale: filing a GitHub Issue on a third-party repository is a public, externally-visible action with no natural automation trigger (it happens once, not on every release). It is handled as the final task, gated on explicit user confirmation before filing.

## Risks / Trade-offs

- **SPI's build could still fail post-submission** despite passing our own `dump-package` check, if SPI's scheme-detection heuristics behave differently than local `swift build`. Mitigation: this is address-when-observed — if SPI reports a build failure after indexing, a `.spi.yml` can be added then, informed by the actual failure rather than speculation.
- **No control over SPI's indexing timeline** once the issue is filed; it depends on their maintainers/automation. Mitigation: none needed — this is inherent to a third-party service and not a blocker for anything else in this codebase.
