## 1. Swift SDK Library Specs

- [x] 1.1 Add Swift SDK child change for library backend behavior
- [x] 1.2 Add `swift-library-client-behavior` capability delta spec
- [x] 1.3 Add `swift-authentication-flow` delta spec for session-aware library operations

## 2. Swift SDK Implementation

- [x] 2.1 Implement Swift SDK operations for library list/detail workflows
- [x] 2.2 Implement session-aware error handling behavior for library operations
- [x] 2.3 Add tests covering successful and failure behavior for library SDK operations
- [x] 2.4 Bump the `API` submodule to pick up product-list/product-list-item create and delete schemas
- [x] 2.5 Implement Swift SDK operations for prepare-download, product-list, and product-list-item (list/create/delete) workflows
- [x] 2.6 Add `BearerTokenMiddleware` and wire it into `SDK.configure()` so library requests carry the session's bearer token
- [x] 2.7 Add tests covering the full library operation surface and bearer-token attachment
