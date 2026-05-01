import Foundation

public struct AuthTokenResponse: Equatable, Sendable {
    public let token: String
    public let refreshToken: String
    public let refreshTokenExpiresAt: Date

    public init(token: String, refreshToken: String, refreshTokenExpiresAt: Date) {
        self.token = token
        self.refreshToken = refreshToken
        self.refreshTokenExpiresAt = refreshTokenExpiresAt
    }
}

public struct AuthSession: Equatable, Sendable {
    public let token: String
    public let refreshToken: String
    public let refreshTokenExpiresAt: Date

    public init(token: String, refreshToken: String, refreshTokenExpiresAt: Date) {
        self.token = token
        self.refreshToken = refreshToken
        self.refreshTokenExpiresAt = refreshTokenExpiresAt
    }

    public init(response: AuthTokenResponse) {
        self.init(
            token: response.token,
            refreshToken: response.refreshToken,
            refreshTokenExpiresAt: response.refreshTokenExpiresAt
        )
    }

    public func isRefreshTokenExpired(at date: Date = Date()) -> Bool {
        date >= refreshTokenExpiresAt
    }
}

public struct SessionTransition: Equatable, Sendable {
    public let nextSession: AuthSession?
    public let error: AuthSessionError

    public init(nextSession: AuthSession?, error: AuthSessionError) {
        self.nextSession = nextSession
        self.error = error
    }
}

extension SDK {
    @discardableResult
    public func authenticate() async throws -> AuthSession {
        let config = try requireConfig()
        let client = try requireClient()

        let output = try await client.postDTRPGAPIVERSIONAuthKey(
            .init(path: .init(dtrpgApiVersion: config.apiVersion))
        )

        switch output {
        case .ok(let ok):
            let payload = try ok.body.json

            return applyAuthResponse(
                AuthTokenResponse(
                    token: payload.token,
                    refreshToken: payload.refreshToken,
                    refreshTokenExpiresAt: Date(timeIntervalSince1970: TimeInterval(payload.refreshTokenTTL))
                )
            )
        case .unauthorized(let unauthorized):
            throw SDKError.authSession(try AuthSessionError(apiError: unauthorized.body.json))
        case .default(let statusCode, _):
            throw SDKError.authenticationFailed(statusCode: statusCode)
        }
    }
}

private extension AuthSessionError {
    init(apiError: Components.Schemas.AuthSessionError) {
        self.init(
            errorCode: apiError.errorCode,
            message: apiError.message,
            authState: AuthState(apiState: apiError.authState)
        )
    }
}

private extension AuthState {
    init(apiState: Components.Schemas.AuthSessionError.AuthStatePayload) {
        switch apiState {
        case .unauthenticated:
            self = .unauthenticated
        case .tokenInvalid:
            self = .tokenInvalid
        case .tokenExpired:
            self = .tokenExpired
        case .refreshExpired:
            self = .refreshExpired
        case .unauthorized:
            self = .unauthorized
        }
    }
}
