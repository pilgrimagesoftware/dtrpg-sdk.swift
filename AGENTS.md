# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Project

This is a Swift SDK for the DriveThruRPG API. The SDK is auto-generated from an OpenAPI specification using Apple's Swift OpenAPI Generator, with custom wrapper code providing a clean, Swift-native interface.

## Architecture

### Code Generation
The SDK uses **Swift OpenAPI Generator** as a build plugin to automatically generate client code from the OpenAPI specification:
- OpenAPI spec: `API/openapi.yaml` (symlinked from the `../API` submodule)
- Generator config: `Sources/SDK/openapi-generator-config.yaml`
- Generated code is created at build time (not checked into source control)
- Configuration generates public types and client with idiomatic Swift naming

### Project Structure
- `Sources/SDK/` - SDK implementation
  - `SDK.swift` - Main SDK singleton class with configuration and client initialization
  - `Auth.swift` - Authentication methods (extends SDK)
  - `Config.swift` - Configuration struct (API key, optional custom URL)
  - `Errors.swift` - SDK-specific error types
  - `OrderProducts.swift` - Product ordering functionality (currently empty)
  - `openapi.yaml` - Symlink to `../../API/openapi.yaml`
  - `openapi-generator-config.yaml` - Generator configuration
- `Tests/SDKTests/` - Test suite
- `API/` - Git submodule containing the OpenAPI specification (shared across all language SDKs)

### SDK Architecture Pattern
The SDK follows a **singleton pattern** with a shared instance (`SDK.shared`):
1. Configure the SDK with `Config` (API key + optional URL)
2. Authentication happens via `authenticate()` which uses the generated OpenAPI client
3. The underlying `Client` from OpenAPI generator is wrapped and exposed through SDK methods
4. Uses `URLSessionTransport` for HTTP communication

### Key Dependencies
- `swift-openapi-generator` (1.10.0+) - Code generation plugin
- `swift-openapi-runtime` (1.9.0+) - Runtime support for generated code
- `swift-openapi-urlsession` (1.0.0+) - URLSession-based transport

## Common Commands

### Build
```bash
swift build
```

### Run Tests
```bash
swift test
```

### Run Single Test
```bash
swift test --filter <test-name>
```

### Clean Build Artifacts
```bash
swift package clean
```

### Generate Documentation
```bash
swift package --allow-writing-to-directory docs \
      generate-documentation \
      --target DriveThruRPGSDK \
      --output-path docs \
      --disable-indexing \
      --transform-for-static-hosting \
      --hosting-base-path dtrpg-sdk-swift
```

### Update API Submodule
Since the OpenAPI spec is in a git submodule:
```bash
cd API
git pull origin main
cd ..
git add API
git commit -m "Update API specification"
```

## Swift Version

This project uses **Swift 6.2.3** (specified in `.swift-version`). The package requires **macOS 15+** and uses Swift 5 language mode with the `ExistentialAny` upcoming feature enabled.

## CI/CD Pipeline

- **PR Workflow** (`.github/workflows/swift-pr.yaml`) - Runs on pull requests to `develop`: manifest validation,
  build, and tests on Linux and macOS (Apple Silicon).
- **CI Workflow** (`.github/workflows/swift-ci.yaml`) - Runs on pushes to `develop`: build, test, and DocC
  generation/publish to `gh-pages`.
- **Release pipeline** (`.github/workflows/prepare-release.yaml`, `tag-release.yaml`, `release.yaml`) - See
  [RELEASE.md](RELEASE.md). Releases are deliberate (triggered via `workflow_dispatch`), not automatic on every
  push to `develop`: a changelog PR is opened against `master`, merging it tags the release, and the tag push
  builds, tests, publishes the GitHub Release, and syncs `master` back into `develop`.

## Development Notes

### Adding New API Endpoints
1. Update the OpenAPI specification in the `API/` submodule
2. Commit and push changes to the API submodule repository
3. Update the submodule reference in this repository
4. Add wrapper methods in `Sources/SDK/*.swift` to expose the generated client methods
5. The OpenAPI Generator plugin will automatically regenerate client code on next build

### Error Handling
Custom errors are defined in `Errors.swift`:
- `SDKError.uninitialized` - Client not initialized
- `SDKError.unconfigured` - SDK not configured with Config

### Testing Framework
The project uses Swift's native **Testing** framework (not XCTest). Tests import `Testing` and use `@Test` macros.

## Branch Strategy

- Main branch: `master`
- Development branch: `develop`
- PRs should target `develop`
- Releases reach `master` only via the automated release process (see [RELEASE.md](RELEASE.md)); do not push
  or open PRs directly against `master`
