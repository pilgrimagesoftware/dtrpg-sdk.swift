// The Swift Programming Language
// https://docs.swift.org/swift-book

import OpenAPIRuntime
import OpenAPIURLSession
import DriveThruRPG

// Instantiate your chosen transport library.
let transport: any ClientTransport = URLSessionTransport()

public func makeClient() throws -> Client {
// Create a client to connect to a server URL documented in the OpenAPI document.
let client = Client(
    serverURL: try Servers.Server1.url(),
    transport: transport
)

return client
}
