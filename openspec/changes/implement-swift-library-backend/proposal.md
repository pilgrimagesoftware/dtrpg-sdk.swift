## Why

The Swift desktop app integration phase needs real Swift SDK capabilities for library backend communication. The Swift SDK currently has authentication foundations and configuration specs, but needs explicit library workflow behavior for listing products, details, and related operations.

## What Changes

- Add Swift SDK library backend behavior for library workflows consumed by the Swift app.
- Define request, response, and error behavior for list/detail/related library operations.
- Preserve API contract meaning from `dtrpg-api` while exposing Swift-native SDK surface area.

## Capabilities

### New Capabilities
- `swift-library-client-behavior`: Defines Swift SDK behavior for library backend operations used by the app frontend.

### Modified Capabilities
- `swift-authentication-flow`: Clarifies session-aware behavior dependencies for authenticated library backend operations.

## Impact

- `dtrpg-sdk/swift`: Adds backend library behavior used by Swift app integration.
- Depends on upstream `dtrpg-api` library contract changes.
