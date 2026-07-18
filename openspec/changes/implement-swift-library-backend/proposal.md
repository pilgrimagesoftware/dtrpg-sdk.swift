## Why

The Swift desktop app integration phase needs real Swift SDK capabilities for library backend communication. The Swift SDK currently has authentication foundations and configuration specs, but needs explicit library workflow behavior for ordered products, download preparation, and product lists (collections).

This change mirrors the scope and structure already established by `dtrpg-sdk/rust`'s library behavior (`dtrpg-sdk/rust/openspec/changes/archive/2026-06-28-define-rust-library-behavior`), so both SDKs expose equivalent library capabilities to their respective app integrations.

## What Changes

- Add Swift SDK library backend behavior covering all library endpoints: listing and detailing ordered products, preparing downloads, and listing/creating/deleting product lists and product list items.
- Swift SDK library types are the OpenAPI-generated types produced directly from `dtrpg-api`'s `openapi.yaml` (via `swift-openapi-generator`), so field names, optionality, and nesting always match the API contract exactly with no hand-authored reinterpretation.
- Require every library request to carry both the `applicationKey` query parameter and an `Authorization: Bearer <token>` header, matching the Rust SDK's dual-authentication requirement.
- Bump the `dtrpg-api` submodule to pick up the product-list/product-list-item create and delete endpoints already implemented by the Rust SDK.

## Capabilities

### New Capabilities
- `swift-library-client-behavior`: Defines Swift SDK behavior for library backend operations used by the app frontend.

### Modified Capabilities
- `swift-authentication-flow`: Clarifies session-aware behavior dependencies for authenticated library backend operations, including bearer-token attachment.

## Impact

- `dtrpg-sdk/swift`: Adds backend library behavior used by Swift app integration.
- `dtrpg-sdk/swift`'s `API` submodule is bumped to a newer `dtrpg-api` commit to gain product-list/product-list-item CRUD schemas.
- Depends on upstream `dtrpg-api` library contract changes.
