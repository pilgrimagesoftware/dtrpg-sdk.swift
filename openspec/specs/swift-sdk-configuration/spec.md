## Purpose
Define how the Swift SDK accepts and applies caller configuration so SDK initialization stays explicit, Swift-native, and aligned with the underlying API contract.

## Requirements

### Requirement: Swift SDK configuration must be explicit before use
The Swift SDK MUST require the configuration values needed to initialize its client behavior before authenticated operations are attempted.

#### Scenario: Attempting to use the SDK without configuration
- **WHEN** a caller invokes authenticated Swift SDK behavior before providing the required configuration
- **THEN** the SDK surfaces the documented unconfigured or uninitialized behavior

### Requirement: Swift SDK configuration must remain Swift-native
The Swift SDK MUST expose configuration in a form that fits Swift conventions while preserving the underlying API contract requirements, including the application key and API version.

#### Scenario: Configuring a custom API endpoint
- **WHEN** a caller provides a supported custom base URL or application key through the Swift SDK configuration surface
- **THEN** the SDK applies that configuration using the documented Swift-native configuration model

#### Scenario: Configuring the API version
- **WHEN** a caller provides or omits the API version
- **THEN** the Swift SDK uses the caller-provided version or the documented default version when building generated-client operation inputs

### Requirement: Swift SDK client types must be generated from OpenAPI
The Swift SDK MUST use Swift OpenAPI Generator against `Sources/SDK/openapi.yaml`, which resolves to the SDK's synchronized OpenAPI contract file.

#### Scenario: Building the Swift SDK
- **WHEN** SwiftPM builds the SDK target
- **THEN** the OpenAPI Generator plugin generates the client and types from the synchronized `openapi.yaml` file
