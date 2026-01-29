extension SDK {
    public func authenticate() async throws {
        guard let config = self.config else {
            throw SDKError.unconfigured
        }
        guard let client = self.client else {
            throw SDKError.uninitialized
        }

        // Perform authentication operations using the client.
        try await client.postDTRPGAPIVERSIONAuthKey(config.apiKey)
    }
}
