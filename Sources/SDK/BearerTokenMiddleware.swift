import Foundation
import HTTPTypes
import OpenAPIRuntime

/// Attaches the active session's bearer token to every request, alongside the
/// application key applied by `ApplicationKeyMiddleware`. Library endpoints require both
/// simultaneously; requests made before authentication simply omit the header.
struct BearerTokenMiddleware: ClientMiddleware {
    let tokenProvider: @Sendable () -> String?

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        if let token = tokenProvider() {
            request.headerFields[.authorization] = "Bearer \(token)"
        }
        return try await next(request, body, baseURL)
    }
}
