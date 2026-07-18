import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

public final class SDK {
    public static let shared = SDK()

    private let transport: any ClientTransport = URLSessionTransport()
    var client: (any APIProtocol)?
    public private(set) var config: Config?
    public private(set) var session: AuthSession?

    public init() {}

    init(config: Config) {
        self.config = config
    }

    init(client: any APIProtocol, config: Config? = nil, session: AuthSession? = nil) {
        self.client = client
        self.config = config
        self.session = session
    }

    public func configure(with config: Config) throws {
        let url = if let urlString = config.url, let url = URL(string: urlString) {
            url
        } else {
            try Servers.Server1.url()
        }
        self.config = config
        client = Client(
            serverURL: url,
            transport: transport,
            middlewares: [
                ApplicationKeyMiddleware(apiKey: config.apiKey),
                BearerTokenMiddleware(tokenProvider: { [weak self] in self?.session?.token })
            ]
        )
    }

    public func requireConfig() throws -> Config {
        guard let config else {
            throw SDKError.unconfigured
        }

        return config
    }

    public func requireClient() throws -> any APIProtocol {
        guard let client else {
            throw SDKError.uninitialized
        }

        return client
    }

    public func requireSession() throws -> AuthSession {
        guard let session else {
            throw SDKError.authSession(
                AuthSessionError(
                    errorCode: AuthState.unauthenticated.rawValue,
                    message: "SDK does not have an authenticated session.",
                    authState: .unauthenticated
                )
            )
        }

        return session
    }

    public func applyAuthResponse(_ response: AuthTokenResponse) -> AuthSession {
        let session = AuthSession(response: response)
        self.session = session
        return session
    }

    public func clearSession() {
        session = nil
    }

    @discardableResult
    public func invalidateSession(error: AuthSessionError) throws -> AuthSessionError {
        _ = try requireSession()
        clearSession()
        return error
    }
}
