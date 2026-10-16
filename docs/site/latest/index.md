---
title: dtrpg-sdk.swift documentation
version: latest
slug: index
---

# dtrpg-sdk.swift documentation

A Swift SDK for the [DriveThruRPG API](https://api.drivethrurpg.com). Provides configuration,
authentication/session lifecycle, and library backend operations for listing and downloading
ordered products and managing product lists (collections).

Requires macOS 15+ and Swift 6.2+.

## Installation

Add the package to `Package.swift`:

```swift
.package(url: "https://github.com/pilgrimagesoftware/dtrpg-sdk.swift.git", from: "1.0.0")
```

## Quick start

```swift
import DriveThruRPGSDK

let sdk = SDK()
try sdk.configure(with: Config(apiKey: "my-app-key"))

// After receiving an auth response from the API:
let session = try await sdk.authenticate()

// Library operations require an active session:
let library = try await sdk.listOrderProducts(LibraryItemsParams(library: true))
```

See [Usage examples]({{ '/latest/usage/' | relative_url }}) for library operations and
collection management, and the
[Swift Package Index documentation](https://swiftpackageindex.com/pilgrimagesoftware/dtrpg-sdk.swift/documentation)
for the full generated API reference (`Config`, `AuthSession`/`AuthState`, and every method's
parameter and return types).
