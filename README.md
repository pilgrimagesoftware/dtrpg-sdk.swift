# dtrpg-sdk.swift

[![PR](https://github.com/pilgrimagesoftware/dtrpg-sdk.swift/actions/workflows/pr.yaml/badge.svg?branch=develop)](https://github.com/pilgrimagesoftware/dtrpg-sdk.swift/actions/workflows/pr.yaml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpilgrimagesoftware%2Fdtrpg-sdk.swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/pilgrimagesoftware/dtrpg-sdk.swift)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpilgrimagesoftware%2Fdtrpg-sdk.swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/pilgrimagesoftware/dtrpg-sdk.swift)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)

A Swift SDK for the [DriveThruRPG API](https://api.drivethrurpg.com).

Provides configuration, authentication/session lifecycle, and library backend operations for listing and
downloading ordered products and managing product lists (collections).

Requires macOS 15+ and Swift 6.2+ (see `.swift-version`).

## Installation

Add the package to `Package.swift`:

```swift
.package(url: "https://github.com/pilgrimagesoftware/dtrpg-sdk.swift.git", from: "1.0.0")
```

## Building from source

This repository uses the `dtrpg-api` repository as a submodule (`API/`). `Sources/SDK/openapi.yaml` symlinks to
`API/openapi.yaml`, which `swift-openapi-generator` reads at build time. Clone with submodules, or initialize them
after cloning:

```bash
git clone --recursive https://github.com/pilgrimagesoftware/dtrpg-sdk.swift.git

# or, if already cloned:
git submodule update --init --recursive
```

## Quick Start

```swift
import DriveThruRPGSDK

let sdk = SDK()
try sdk.configure(with: Config(apiKey: "my-app-key"))

// After receiving an auth response from the API:
let session = try await sdk.authenticate()

// Library operations require an active session:
let library = try await sdk.listOrderProducts(LibraryItemsParams(library: true))
```

See the [Swift Package Index documentation](https://swiftpackageindex.com/pilgrimagesoftware/dtrpg-sdk.swift/documentation)
for the full API reference, including `Config`, `AuthSession`/`AuthState`, and the library operations
(`listOrderProducts`, `getOrderProduct`, `prepareDownload`, `listProductLists`, `createProductList`, and more).

## Development

```bash
swift build
swift test
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for commit conventions and branch/PR expectations.

## Release Process

See [RELEASE.md](RELEASE.md).

## License

MIT — see [LICENSE.md](LICENSE.md).
