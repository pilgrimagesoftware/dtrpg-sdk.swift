import Foundation

/// A downloadable file belonging to a library item.
public struct LibraryFile: Equatable, Sendable {
    public let title: String
    public let filename: String
    public let size: Int

    public init(title: String, filename: String, size: Int) {
        self.title = title
        self.filename = filename
        self.size = size
    }

    init(file: Components.Schemas.OrderProductFile) {
        self.init(title: file.title, filename: file.filename, size: file.size)
    }
}

/// A single item in the authenticated user's library, mapped from the API's order product resource.
public struct LibraryItem: Equatable, Sendable {
    public let orderProductId: Int
    public let productId: Int
    public let name: String
    public let isbn: String?
    public let finalPrice: Double
    public let quantity: Int
    public let isArchived: Bool
    public let files: [LibraryFile]
    public let fileLastModified: Date?
    public let fileLastDownloaded: Date?

    public init(
        orderProductId: Int,
        productId: Int,
        name: String,
        isbn: String? = nil,
        finalPrice: Double,
        quantity: Int,
        isArchived: Bool,
        files: [LibraryFile],
        fileLastModified: Date? = nil,
        fileLastDownloaded: Date? = nil
    ) {
        self.orderProductId = orderProductId
        self.productId = productId
        self.name = name
        self.isbn = isbn
        self.finalPrice = finalPrice
        self.quantity = quantity
        self.isArchived = isArchived
        self.files = files
        self.fileLastModified = fileLastModified
        self.fileLastDownloaded = fileLastDownloaded
    }

    init(item: Components.Schemas.OrderProductItem) {
        let attributes = item.attributes
        self.init(
            orderProductId: attributes.orderProductId,
            productId: attributes.productId,
            name: attributes.name,
            isbn: attributes.isbn,
            finalPrice: attributes.finalPrice,
            quantity: attributes.quantity,
            isArchived: attributes.archived != 0,
            files: attributes.files.map(LibraryFile.init),
            fileLastModified: attributes.fileLastModified,
            fileLastDownloaded: attributes.fileLastDownloaded
        )
    }
}

/// A single page of library items with the pagination position it was fetched at.
public struct LibraryPage: Equatable, Sendable {
    public let items: [LibraryItem]
    public let currentPage: Int
    public let itemsPerPage: Int

    public init(items: [LibraryItem], currentPage: Int, itemsPerPage: Int) {
        self.items = items
        self.currentPage = currentPage
        self.itemsPerPage = itemsPerPage
    }

    init(response: Components.Schemas.OrderProductListResponse) {
        self.init(
            items: response.data.map(LibraryItem.init),
            currentPage: response.meta.currentPage,
            itemsPerPage: response.meta.itemsPerPage
        )
    }
}

extension SDK {
    /// Lists the authenticated user's library items, requiring an active session.
    ///
    /// - Throws: `SDKError.authSession` if the session is missing or the backend rejects the request.
    @discardableResult
    public func listLibraryItems(page: Int? = nil, pageSize: Int? = nil) async throws -> LibraryPage {
        _ = try requireSession()
        let config = try requireConfig()
        let client = try requireClient()

        let output = try await client.getDTRPGAPIVERSIONOrderProducts(
            .init(
                path: .init(dtrpgApiVersion: config.apiVersion),
                query: .init(page: page, pageSize: pageSize, library: true)
            )
        )

        switch output {
        case .ok(let ok):
            return LibraryPage(response: try ok.body.json)
        case .default(_, let response):
            throw try invalidateLibrarySession(dueTo: response.body.json)
        }
    }

    /// Retrieves a single library item's detail by its order product ID, requiring an active session.
    ///
    /// - Throws: `SDKError.authSession` if the session is missing or the backend rejects the request,
    ///   or `SDKError.libraryItemNotFound` if the backend returns no item data.
    @discardableResult
    public func libraryItemDetail(orderProductId: Int) async throws -> LibraryItem {
        _ = try requireSession()
        let config = try requireConfig()
        let client = try requireClient()

        let output = try await client.getDTRPGAPIVERSIONOrderProductsOrderProductId(
            .init(path: .init(dtrpgApiVersion: config.apiVersion, orderProductId: orderProductId))
        )

        switch output {
        case .ok(let ok):
            guard let item = try ok.body.json.data else {
                throw SDKError.libraryItemNotFound(orderProductId: orderProductId)
            }
            return LibraryItem(item: item)
        case .default(_, let response):
            throw try invalidateLibrarySession(dueTo: response.body.json)
        }
    }

    private func invalidateLibrarySession(
        dueTo apiError: Components.Schemas.AuthSessionError
    ) throws -> SDKError {
        let sessionError = AuthSessionError(apiError: apiError)
        try invalidateSession(error: sessionError)
        return .authSession(sessionError)
    }
}
