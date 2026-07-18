import Foundation
import HTTPTypes
import OpenAPIRuntime

struct ApplicationKeyMiddleware: ClientMiddleware {
    let apiKey: String

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        request.path = request.pathWithQueryItem(name: "applicationKey", value: apiKey)
        return try await next(request, body, baseURL)
    }
}

private extension HTTPRequest {
    func pathWithQueryItem(name: String, value: String) -> String {
        let path = self.path ?? "/"
        let separator = path.contains("?") ? "&" : "?"
        var allowedCharacters = CharacterSet.urlQueryAllowed
        allowedCharacters.remove(charactersIn: "=&+?")
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? name
        let encodedValue = value.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? value

        return "\(path)\(separator)\(encodedName)=\(encodedValue)"
    }
}
