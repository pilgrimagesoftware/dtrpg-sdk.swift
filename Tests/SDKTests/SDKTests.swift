import Foundation
import Testing
@testable import SDK

@Test func configureStoresConfigAndInitializesGeneratedClient() throws {
    let sdk = SDK()
    let config = Config(apiKey: "app-key", url: "https://example.test/api", apiVersion: "vTest")

    try sdk.configure(with: config)

    #expect(sdk.config == config)
    _ = try sdk.requireClient()
}

@Test func authenticateRequiresConfiguration() async throws {
    let sdk = SDK(client: AuthClientStub(output: .successOutput()))

    await #expect(throws: SDKError.unconfigured) {
        try await sdk.authenticate()
    }
}

@Test func authenticateRequiresInitializedClient() async throws {
    let sdk = SDK(config: Config(apiKey: "app-key"))

    await #expect(throws: SDKError.uninitialized) {
        try await sdk.authenticate()
    }
}

@Test func authenticateBuildsGeneratedInputAndStoresSession() async throws {
    let client = AuthClientStub(output: .successOutput())
    let sdk = SDK(
        client: client,
        config: Config(apiKey: "app-key", apiVersion: "vTest")
    )

    let session = try await sdk.authenticate()

    #expect(client.authInput?.path.dtrpgApiVersion == "vTest")
    #expect(session.token == "jwt")
    #expect(session.refreshToken == "refresh")
    #expect(session.refreshTokenExpiresAt == Date(timeIntervalSince1970: 1_800_000_000))
    #expect(sdk.session == session)
}

@Test func authenticateMapsUnauthorizedResponseToAuthSessionError() async throws {
    let apiError = Components.Schemas.AuthSessionError(
        errorCode: AuthState.unauthorized.rawValue,
        message: "Application key is not authorized.",
        authState: .unauthorized
    )
    let sdk = SDK(
        client: AuthClientStub(output: .unauthorized(.init(body: .json(apiError)))),
        config: Config(apiKey: "app-key")
    )

    await #expect(throws: SDKError.authSession(.init(
        errorCode: AuthState.unauthorized.rawValue,
        message: "Application key is not authorized.",
        authState: .unauthorized
    ))) {
        try await sdk.authenticate()
    }
}

@Test func authenticateSurfacesNonSuccessStatus() async throws {
    let apiError = Components.Schemas.AuthSessionError(
        errorCode: AuthState.tokenInvalid.rawValue,
        message: "Token invalid.",
        authState: .tokenInvalid
    )
    let sdk = SDK(
        client: AuthClientStub(output: .default(statusCode: 500, .init(body: .json(apiError)))),
        config: Config(apiKey: "app-key")
    )

    await #expect(throws: SDKError.authenticationFailed(statusCode: 500)) {
        try await sdk.authenticate()
    }
}

@Test func requireSessionThrowsUnauthenticatedError() throws {
    let sdk = SDK()

    do {
        _ = try sdk.requireSession()
        Issue.record("Expected requireSession to throw")
    } catch let error as SDKError {
        #expect(error == .authSession(.init(
            errorCode: AuthState.unauthenticated.rawValue,
            message: "SDK does not have an authenticated session.",
            authState: .unauthenticated
        )))
    }
}

@Test func invalidateSessionClearsSessionAndReturnsError() throws {
    let session = AuthSession(
        token: "jwt",
        refreshToken: "refresh",
        refreshTokenExpiresAt: Date(timeIntervalSince1970: 1_800_000_000)
    )
    let sdk = SDK(
        client: AuthClientStub(output: .successOutput()),
        session: session
    )
    let error = AuthSessionError(
        errorCode: AuthState.tokenExpired.rawValue,
        message: "Token expired.",
        authState: .tokenExpired
    )

    let returnedError = try sdk.invalidateSession(error: error)

    #expect(returnedError == error)
    #expect(sdk.session == nil)
}

final class AuthClientStub: APIProtocol, @unchecked Sendable {
    var authInput: Operations.PostDTRPGAPIVERSIONAuthKey.Input?
    let output: Operations.PostDTRPGAPIVERSIONAuthKey.Output

    init(output: Operations.PostDTRPGAPIVERSIONAuthKey.Output) {
        self.output = output
    }

    func postDTRPGAPIVERSIONAuthKey(
        _ input: Operations.PostDTRPGAPIVERSIONAuthKey.Input
    ) async throws -> Operations.PostDTRPGAPIVERSIONAuthKey.Output {
        authInput = input
        return output
    }

    func getDTRPGAPIVERSIONOrderProducts(
        _ input: Operations.GetDTRPGAPIVERSIONOrderProducts.Input
    ) async throws -> Operations.GetDTRPGAPIVERSIONOrderProducts.Output {
        fatalError("Not used by auth tests")
    }

    func getDTRPGAPIVERSIONOrderProductsOrderProductId(
        _ input: Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductId.Input
    ) async throws -> Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductId.Output {
        fatalError("Not used by auth tests")
    }

    func getDTRPGAPIVERSIONOrderProductsOrderProductIdPrepare(
        _ input: Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductIdPrepare.Input
    ) async throws -> Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductIdPrepare.Output {
        fatalError("Not used by auth tests")
    }

    func getDTRPGAPIVERSIONProductLists(
        _ input: Operations.GetDTRPGAPIVERSIONProductLists.Input
    ) async throws -> Operations.GetDTRPGAPIVERSIONProductLists.Output {
        fatalError("Not used by auth tests")
    }

    func getDTRPGAPIVERSIONProductListItems(
        _ input: Operations.GetDTRPGAPIVERSIONProductListItems.Input
    ) async throws -> Operations.GetDTRPGAPIVERSIONProductListItems.Output {
        fatalError("Not used by auth tests")
    }
}

private extension Operations.PostDTRPGAPIVERSIONAuthKey.Output {
    static func successOutput() -> Self {
        .ok(.init(body: .json(.init(
            token: "jwt",
            refreshToken: "refresh",
            refreshTokenTTL: 1_800_000_000
        ))))
    }
}
