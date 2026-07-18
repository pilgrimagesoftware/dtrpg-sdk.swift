public enum SDKError: Error, Equatable {
    case uninitialized
    case unconfigured
    case malformedAuthResponse
    case authenticationFailed(statusCode: Int)
    case authSession(AuthSessionError)
    case libraryItemNotFound(orderProductId: Int)
}

public enum AuthState: String, Equatable, Sendable {
    case unauthenticated
    case tokenInvalid = "token_invalid"
    case tokenExpired = "token_expired"
    case refreshExpired = "refresh_expired"
    case unauthorized
}

public struct AuthSessionError: Error, Equatable, Sendable {
    public let errorCode: String
    public let message: String
    public let authState: AuthState

    public init(errorCode: String, message: String, authState: AuthState) {
        self.errorCode = errorCode
        self.message = message
        self.authState = authState
    }
}
