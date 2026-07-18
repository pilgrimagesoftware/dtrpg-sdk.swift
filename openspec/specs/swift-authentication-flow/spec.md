## Purpose
Define how the Swift SDK wraps authentication around the generated client so callers get predictable Swift-facing behavior without losing the meaning of API failures.

## Requirements

### Requirement: Swift authentication flow must wrap the generated client predictably
The Swift SDK MUST define how its handwritten authentication surface coordinates with the generated API client and stores the resulting authenticated session, including the authenticated prerequisites for library workflow operations.

#### Scenario: Authenticating through the Swift SDK
- **WHEN** a caller triggers authentication through the Swift SDK wrapper
- **THEN** the wrapper uses the generated client, applies the configured API version, and returns behavior consistent with the documented Swift authentication flow

#### Scenario: Authentication succeeds
- **WHEN** the generated client returns a successful token response
- **THEN** the Swift SDK converts the response into a Swift `AuthSession` and stores it as the active session

### Requirement: Swift authentication flow must expose session lifecycle operations
The Swift SDK MUST expose Swift-native operations for requiring, applying, clearing, and invalidating authentication sessions, including session handling that library workflow operations depend on.

#### Scenario: Requiring a missing session
- **WHEN** a caller requires an authenticated session before one exists
- **THEN** the Swift SDK surfaces the documented unauthenticated session error

#### Scenario: Invalidating an active session
- **WHEN** the SDK invalidates an active session because of an auth/session failure
- **THEN** it clears the stored session while preserving the error that caused the invalidation

### Requirement: Swift authentication flow must attach the active session's bearer token to outgoing requests
The Swift SDK MUST read the current session at request time and attach its token as an `Authorization: Bearer <token>` header, so that library workflow operations are authenticated without each operation managing the header itself.

#### Scenario: Session is active when a request is sent
- **WHEN** the SDK sends any request while an active session exists
- **THEN** the request carries an `Authorization: Bearer <token>` header using the current session's token

#### Scenario: No session exists when a request is sent
- **WHEN** the SDK sends a request while no session exists
- **THEN** the request omits the `Authorization` header entirely

### Requirement: Swift authentication errors must preserve API meaning
The Swift SDK MUST translate authentication failures into Swift-facing behavior without obscuring the meaning of the underlying API failure.

#### Scenario: Authentication request fails
- **WHEN** the underlying API call fails during Swift authentication
- **THEN** the Swift SDK surfaces that failure through its documented Swift error behavior

#### Scenario: Authentication response is incomplete
- **WHEN** the API returns a success response without the required token, refresh token, or refresh expiry fields
- **THEN** the Swift SDK reports a malformed authentication response rather than storing a partial session
