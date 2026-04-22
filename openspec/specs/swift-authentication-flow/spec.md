## Purpose
Define how the Swift SDK wraps authentication around the generated client so callers get predictable Swift-facing behavior without losing the meaning of API failures.

## Requirements

### Requirement: Swift authentication flow must wrap the generated client predictably
The Swift SDK MUST define how its handwritten authentication surface coordinates with the generated API client.

#### Scenario: Authenticating through the Swift SDK
- **WHEN** a caller triggers authentication through the Swift SDK wrapper
- **THEN** the wrapper uses the generated client and returns behavior consistent with the documented Swift authentication flow

### Requirement: Swift authentication errors must preserve API meaning
The Swift SDK MUST translate authentication failures into Swift-facing behavior without obscuring the meaning of the underlying API failure.

#### Scenario: Authentication request fails
- **WHEN** the underlying API call fails during Swift authentication
- **THEN** the Swift SDK surfaces that failure through its documented Swift error behavior
