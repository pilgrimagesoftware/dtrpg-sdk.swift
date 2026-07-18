## Purpose
Define Swift SDK behavior for library backend operations (ordered products, download preparation, product lists and items) used by the Swift app frontend.

## Requirements

### Requirement: Swift SDK MUST provide authenticated operations for all library endpoints
The Swift SDK MUST expose Swift-native operations for every library endpoint defined by the API contract: listing ordered products, retrieving ordered product detail, preparing a download, listing product lists, creating a product list, deleting a product list, listing product list items, adding a product list item, and deleting a product list item.

#### Scenario: Listing library items through Swift SDK
- **WHEN** a caller requests authenticated library content through the Swift SDK
- **THEN** the SDK performs the documented library operation and returns Swift-facing result behavior

#### Scenario: Managing product lists through Swift SDK
- **WHEN** a caller creates, lists, or deletes a product list or product list item through the Swift SDK
- **THEN** the SDK performs the documented operation and returns Swift-facing result behavior

### Requirement: Swift SDK library operations MUST preserve API contract meaning
The Swift SDK MUST map API responses and failures for library workflows into Swift-facing behavior without changing the meaning of API-owned fields and errors.

#### Scenario: Library operation receives backend failure
- **WHEN** the backend returns an error for a library workflow request
- **THEN** the Swift SDK surfaces Swift-facing failure behavior that preserves API-defined error semantics

### Requirement: Swift library types MUST derive their structure from API contract schemas
Swift SDK library operations MUST return types generated directly from the API contract's OpenAPI document rather than hand-authored types that reinterpret, rename, or drop API-defined fields.

#### Scenario: Adding a new field to a library resource
- **WHEN** the API contract adds a new field to an ordered product or product list schema
- **THEN** the Swift SDK's generated types reflect the API-defined change automatically on the next build, without requiring a hand-authored type update

### Requirement: Swift SDK library operations MUST support app adapter usage
The Swift SDK library surface MUST provide deterministic behavior suitable for consumption by Swift app adapter layers.

#### Scenario: Swift app adapter invokes SDK library operations
- **WHEN** app integration code calls SDK library APIs for list/detail/collection behavior
- **THEN** the SDK surface supports predictable success/failure handling and session-aware behavior for adapter-driven app state transitions

### Requirement: Swift SDK MUST authenticate every library request using both the application key and the bearer token
Every library API request MUST include the `applicationKey` query parameter and the `Authorization: Bearer <token>` header from the active session.

#### Scenario: Sending an authenticated library request
- **WHEN** the Swift SDK sends a request to any library endpoint
- **THEN** the request includes both the application key and the bearer token from the active session

#### Scenario: Sending the authentication request before a session exists
- **WHEN** the Swift SDK sends the initial authentication request, before any session exists
- **THEN** the request includes the application key but omits the `Authorization` header
