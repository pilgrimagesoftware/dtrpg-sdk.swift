public struct Config: Equatable, Sendable {
    public let apiKey: String
    public let url: String?

    public let apiVersion: String

    public init(apiKey: String, url: String? = nil, apiVersion: String = "vBeta") {
        self.apiKey = apiKey
        self.url = url
        self.apiVersion = apiVersion
    }
}
