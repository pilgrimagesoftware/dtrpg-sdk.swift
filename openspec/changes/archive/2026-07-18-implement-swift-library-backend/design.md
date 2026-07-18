## Context

Swift app frontend integration needs stable Swift SDK operations for authenticated library communication. Swift SDK should define these behaviors in a dedicated child change so app code depends on stable SDK semantics rather than ad hoc API calls.

The Rust SDK already implements the equivalent capability (`rust-library-client` / `rust-library-types`, archived under `dtrpg-sdk/rust/openspec/changes/archive/2026-06-28-define-rust-library-behavior`) and has since grown to cover product-list and product-list-item creation/deletion as `dtrpg-api` added those endpoints. This change brings the Swift SDK to the same operational surface: list/detail ordered products, prepare downloads, and list/create/delete product lists and product list items.

The API authenticates library requests using two mechanisms simultaneously: an `applicationKey` query parameter (identifies the publisher/application) and an `Authorization: Bearer <token>` header (authenticates the customer session). Both must be present on every library request, mirroring the Rust SDK's `LibraryClient` behavior.

## Goals / Non-Goals

**Goals:**
- Define Swift SDK backend behavior for every library operation the API contract defines: ordered products (list/detail), download preparation, and product lists/product list items (list/create/delete).
- Keep API semantics preserved while exposing Swift-native SDK interfaces — library types are the OpenAPI-generated types themselves, not a hand-authored reinterpretation, so they can never silently drift from the API contract.
- Attach both the application key and the active session's bearer token to every library request.
- Provide predictable error/session behavior for app adapters: a missing or rejected session surfaces as `SDKError.authSession` and clears the stored session.

**Non-Goals:**
- Define app UI behavior.
- Redefine API contracts in SDK specs.
- Model API behavior beyond what `dtrpg-api`'s `openapi.yaml` documents (e.g. the Rust SDK's `relationships`/`included`-item embedding of publisher/product/order metadata is not part of the current contract and is not replicated here).

## Decisions

### Add a dedicated Swift library client behavior capability
Rationale: library communication behavior is distinct from generic auth/config capabilities.

### Modify Swift authentication flow for session-aware library usage
Rationale: app adapters rely on consistent auth/session semantics during backend calls.

### Expose the OpenAPI-generated `Components.Schemas.*` types directly as the library API surface, rather than hand-authoring parallel Swift structs
Rationale: the Rust SDK's `rust-library-types` capability requires its hand-written structs to mirror the API contract field-for-field precisely because Rust has no type-level code generation from `openapi.yaml` (its `build.rs` only extracts an operation list and server URL as a build-time sanity check). Swift's `swift-openapi-generator` plugin already produces types directly from the same `openapi.yaml`, so returning those generated types from SDK methods satisfies the "no SDK-local interpretation" requirement more strongly than a hand-copied mirror ever could, with zero risk of the Swift types drifting from the contract as it evolves.

### Add a `BearerTokenMiddleware` that reads the SDK's current session at request time
Rationale: `ApplicationKeyMiddleware` already attaches the static application key configured at `configure()` time. The bearer token, by contrast, changes across the SDK's lifetime (absent before authentication, present after, cleared on invalidation), so it must be read dynamically per request rather than captured once. The middleware holds a `[weak self]` closure back to the `SDK` instance so it always reflects the live session.

### Bump the `API` submodule to the `dtrpg-api` commit that defines product-list/product-list-item create and delete
Rationale: the previously pinned commit only defined the `GET` operations for `product_lists`/`product_list_items`. The Rust SDK's current `LibraryClient` already implements `create_product_list`, `delete_product_list`, `add_product_list_item`, and `delete_product_list_item` against these endpoints; bumping the submodule is required for Swift's generator to produce the matching operations.

## Risks / Trade-offs

- **Submodule bump is a cross-cutting change**: bumping `API` affects every generated type in the Swift SDK, not just library types. Mitigation: the bump only adds new schemas/paths in this case; existing auth types are unaffected, and the full test suite passes unchanged.
- **No retry or error recovery**: library operations propagate `SDKError.authSession` directly on any auth/session failure. Mitigation: retry logic is application-level policy, consistent with the Rust SDK's same trade-off.
