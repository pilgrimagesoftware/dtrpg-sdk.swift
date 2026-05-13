## Context

Swift app frontend integration needs stable Swift SDK operations for authenticated library communication. Swift SDK should define these behaviors in a dedicated child change so app code depends on stable SDK semantics rather than ad hoc API calls.

## Goals / Non-Goals

**Goals:**
- Define Swift SDK backend behavior for library operations.
- Keep API semantics preserved while exposing Swift-native SDK interfaces.
- Provide predictable error/session behavior for app adapters.

**Non-Goals:**
- Define app UI behavior.
- Redefine API contracts in SDK specs.

## Decisions

Add a dedicated Swift library client behavior capability.
Rationale: library communication behavior is distinct from generic auth/config capabilities.

Modify Swift authentication flow for session-aware library usage.
Rationale: app adapters rely on consistent auth/session semantics during backend calls.
