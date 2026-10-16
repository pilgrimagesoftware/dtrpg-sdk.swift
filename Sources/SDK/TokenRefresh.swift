import Foundation

extension SDK {
    /// Renews the access token using the active session's refresh token.
    ///
    /// Posts to `POST /{apiVersion}/auth/refresh` with the token in a `refreshToken` cookie.
    /// On success the stored session is replaced with the one the API returns, including its
    /// (possibly rotated) refresh token and expiry. On failure the existing session is left in
    /// place, so the caller can retry, fall back to ``authenticate()``, or ``clearSession()``.
    ///
    /// The refresh endpoint is not described by the bundled OpenAPI document, so this call does
    /// not use the generated client. Its shape is inferred from the `Set-Cookie` header on the
    /// `auth_key` response, which scopes the `refreshToken` cookie to `/api/vBeta/auth/refresh`:
    /// the token is sent back as that cookie, and the response is assumed to carry the same
    /// payload as `auth_key`.
    ///
    /// - Throws: ``SDKError/unconfigured`` or an unauthenticated ``SDKError/authSession(_:)``
    ///   if the SDK has no configuration or session; ``SDKError/authSession(_:)`` if the API
    ///   rejects the refresh token with an auth error body; ``SDKError/authenticationFailed(statusCode:)``
    ///   for any other non-success status; ``SDKError/malformedAuthResponse`` if a success body
    ///   cannot be decoded.
    @discardableResult
    public func refreshSession() async throws -> AuthSession {
        let config = try requireConfig()
        let session = try requireSession()
        let request = try makeRefreshRequest(refreshToken: session.refreshToken, config: config)

        let (data, response) = try await refreshSender(request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(statusCode) else {
            throw refreshFailure(statusCode: statusCode, body: data)
        }

        guard let payload = try? JSONDecoder().decode(RefreshPayload.self, from: data) else {
            throw SDKError.malformedAuthResponse
        }
        return applyAuthResponse(
            AuthTokenResponse(
                token: payload.token,
                refreshToken: payload.refreshToken,
                refreshTokenExpiresAt: Date(timeIntervalSince1970: TimeInterval(payload.refreshTokenTTL))
            )
        )
    }

    private func makeRefreshRequest(refreshToken: String, config: Config) throws -> URLRequest {
        let url = try baseURL(for: config)
            .appendingPathComponent(config.apiVersion)
            .appendingPathComponent("auth")
            .appendingPathComponent("refresh")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("refreshToken=\(refreshToken)", forHTTPHeaderField: "Cookie")
        // The cookie is set explicitly above; keep URLSession from layering its own on top.
        request.httpShouldHandleCookies = false
        request.httpBody = Data("{}".utf8)
        return request
    }

    private func refreshFailure(statusCode: Int, body: Data) -> SDKError {
        guard
            let error = try? JSONDecoder().decode(RefreshErrorBody.self, from: body),
            let authState = AuthState(rawValue: error.authState)
        else {
            return .authenticationFailed(statusCode: statusCode)
        }
        return .authSession(
            AuthSessionError(errorCode: error.errorCode, message: error.message, authState: authState)
        )
    }
}

private struct RefreshPayload: Decodable {
    let token: String
    let refreshToken: String
    let refreshTokenTTL: Int
}

private struct RefreshErrorBody: Decodable {
    let errorCode: String
    let message: String
    let authState: String
}
