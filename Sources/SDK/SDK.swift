import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

public class SDK {
    public static let shared = SDK()

    // Instantiate your chosen transport library.
    private let transport: any ClientTransport = URLSessionTransport()
    var client : Client? = nil
    var config : Config? = nil

    public func configure(with config : Config) throws {
        let url = if let urlString = config.url, let url = URL(string: urlString) { url } else { try Servers.Server1.url() }
        client = Client(
            serverURL: url,
            transport: transport
        )
    }
}
