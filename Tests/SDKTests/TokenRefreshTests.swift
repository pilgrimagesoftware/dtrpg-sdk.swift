import Foundation
import Testing
@testable import SDK

private let refreshedBody = Data(
    #"{"token":"new-jwt","refreshToken":"new-refresh","refreshTokenTTL":2000000000}"#.utf8
)

private final class RequestRecorder: @unchecked Sendable {
    var request: URLRequest?
}

private func sdkWithSession(
    statusCode: Int,
    body: Data,
    recorder: RequestRecorder = RequestRecorder()
) -> SDK {
    let sdk = SDK(
        client: AuthClientStub(output: .successOutput()),
        config: Config(apiKey: "app-key", url: "https://example.test/api", apiVersion: "vTest"),
        session: AuthSession(
            token: "old-jwt",
            refreshToken: "old-refresh",
            refreshTokenExpiresAt: Date(timeIntervalSince1970: 1_000_000_000)
        )
    )
    sdk.refreshSender = { request in
        recorder.request = request
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        return (body, response)
    }
    return sdk
}

@Test func refreshSessionSendsTokenAsCookieAndStoresNewSession() async throws {
    let recorder = RequestRecorder()
    let sdk = sdkWithSession(statusCode: 200, body: refreshedBody, recorder: recorder)

    let session = try await sdk.refreshSession()

    #expect(recorder.request?.httpMethod == "POST")
    #expect(recorder.request?.url?.absoluteString == "https://example.test/api/vTest/auth/refresh")
    #expect(recorder.request?.value(forHTTPHeaderField: "Cookie") == "refreshToken=old-refresh")
    #expect(session.token == "new-jwt")
    #expect(session.refreshToken == "new-refresh")
    #expect(session.refreshTokenExpiresAt == Date(timeIntervalSince1970: 2_000_000_000))
    #expect(sdk.session == session)
}

@Test func refreshSessionMapsAuthErrorBodyAndKeepsOldSession() async throws {
    let body = Data(
        #"{"errorCode":"refresh_expired","message":"Refresh token expired.","authState":"refresh_expired"}"#.utf8
    )
    let sdk = sdkWithSession(statusCode: 401, body: body)

    await #expect(throws: SDKError.authSession(.init(
        errorCode: "refresh_expired",
        message: "Refresh token expired.",
        authState: .refreshExpired
    ))) {
        try await sdk.refreshSession()
    }
    #expect(sdk.session?.token == "old-jwt")
}

@Test func refreshSessionSurfacesNonSuccessStatusWithoutAuthBody() async throws {
    let sdk = sdkWithSession(statusCode: 500, body: Data("oops".utf8))

    await #expect(throws: SDKError.authenticationFailed(statusCode: 500)) {
        try await sdk.refreshSession()
    }
}

@Test func refreshSessionRejectsUndecodableSuccessBody() async throws {
    let sdk = sdkWithSession(statusCode: 200, body: Data("not json".utf8))

    await #expect(throws: SDKError.malformedAuthResponse) {
        try await sdk.refreshSession()
    }
}

@Test func refreshSessionRequiresConfigurationAndSession() async throws {
    await #expect(throws: SDKError.unconfigured) {
        try await SDK().refreshSession()
    }

    let unauthenticated = SDK(config: Config(apiKey: "app-key"))
    await #expect(throws: SDKError.self) {
        try await unauthenticated.refreshSession()
    }
}
