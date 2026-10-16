import OpenAPIRuntime
import OpenAPIURLSession
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class SDK {
    public static let shared = SDK()

    private let transport: any ClientTransport = URLSessionTransport()
    var client: (any APIProtocol)?
    public private(set) var config: Config?
    public private(set) var session: AuthSession?

    /// Sends the token refresh request. The refresh endpoint is not in the OpenAPI document,
    /// so it bypasses the generated client; tests replace this to avoid the network.
    var refreshSender: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
        try await URLSession.shared.data(for: request)
    }

    public init() {}

    init(config: Config) {
        self.config = config
    }

    init(client: any APIProtocol, config: Config? = nil, session: AuthSession? = nil) {
        self.client = client
        self.config = config
        self.session = session
    }

    func baseURL(for config: Config) throws -> URL {
        if let urlString = config.url, let url = URL(string: urlString) {
            return url
        }
        return try Servers.Server1.url()
    }

    public func configure(with config: Config) throws {
        let url = try baseURL(for: config)
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
