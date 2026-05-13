## ADDED Requirements

### Requirement: Swift SDK MUST provide authenticated library workflow operations
The Swift SDK MUST expose Swift-native operations for authenticated library workflows, including listing library items and retrieving library item details.

#### Scenario: Listing library items through Swift SDK
- **WHEN** a caller requests authenticated library content through the Swift SDK
- **THEN** the SDK performs the documented library operation and returns Swift-facing result behavior

### Requirement: Swift SDK library operations MUST preserve API contract meaning
The Swift SDK MUST map API responses and failures for library workflows into Swift-facing behavior without changing the meaning of API-owned fields and errors.

#### Scenario: Library operation receives backend failure
- **WHEN** the backend returns an error for a library workflow request
- **THEN** the Swift SDK surfaces Swift-facing failure behavior that preserves API-defined error semantics

### Requirement: Swift SDK library operations MUST support app adapter usage
The Swift SDK library surface MUST provide deterministic behavior suitable for consumption by Swift app adapter layers.

#### Scenario: Swift app adapter invokes SDK library operations
- **WHEN** app integration code calls SDK library APIs for list/detail behavior
- **THEN** the SDK surface supports predictable success/failure handling and session-aware behavior for adapter-driven app state transitions
