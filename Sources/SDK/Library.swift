import Foundation
import OpenAPIRuntime

/// Query parameters for the `order_products` (library items) endpoint.
///
/// All fields are optional; a `nil` value omits the corresponding query parameter.
public struct LibraryItemsParams: Sendable {
    public var page: Int?
    public var pageSize: Int?
    public var getChecksum: Bool?
    public var getFilters: Bool?
    public var library: Bool?
    public var archived: Bool?
    public var updatedDateAfter: Date?

    public init(
        page: Int? = nil,
        pageSize: Int? = nil,
        getChecksum: Bool? = nil,
        getFilters: Bool? = nil,
        library: Bool? = nil,
        archived: Bool? = nil,
        updatedDateAfter: Date? = nil
    ) {
        self.page = page
        self.pageSize = pageSize
        self.getChecksum = getChecksum
        self.getFilters = getFilters
        self.library = library
        self.archived = archived
        self.updatedDateAfter = updatedDateAfter
    }
}

/// Query parameters for paginated collection endpoints such as `product_lists`.
public struct PageParams: Sendable {
    public var page: Int?
    public var pageSize: Int?

    public init(page: Int? = nil, pageSize: Int? = nil) {
        self.page = page
        self.pageSize = pageSize
    }
}

extension SDK {
    /// Lists the authenticated user's ordered products, requiring an active session.
    ///
    /// Maps to `GET /{api_version}/order_products`. Returns the generated response type
    /// directly so callers see exactly what the API contract defines.
    ///
    /// - Throws: `SDKError.authSession` if the session is missing or the backend rejects the request.
    @discardableResult
    public func listOrderProducts(
        _ params: LibraryItemsParams = .init()
    ) async throws -> Components.Schemas.OrderProductListResponse {
        _ = try requireSession()
        let config = try requireConfig()
        let client = try requireClient()

        let output = try await client.getDTRPGAPIVERSIONOrderProducts(
            .init(
                path: .init(dtrpgApiVersion: config.apiVersion),
                query: .init(
                    getChecksum: params.getChecksum.map { $0 ? 1 : 0 },
                    getFilters: params.getFilters.map { $0 ? 1 : 0 },
                    page: params.page,
                    pageSize: params.pageSize,
                    library: params.library,
                    archived: params.archived.map { $0 ? 1 : 0 },
                    updatedDate_lbrack_after_rbrack_: params.updatedDateAfter
                )
            )
        )

        switch output {
        case .ok(let ok):
            return try ok.body.json
        case .default(_, let response):
            throw try invalidateLibrarySession(dueTo: response.body.json)
        }
    }

    /// Retrieves a single ordered product's detail by its order product ID, requiring an active session.
    ///
    /// Maps to `GET /{api_version}/order_products/{orderProductId}`.
    ///
    /// - Throws: `SDKError.authSession` if the session is missing or the backend rejects the request,
    ///   or `SDKError.libraryItemNotFound` if the backend returns no item data.
    @discardableResult
    public func getOrderProduct(orderProductId: Int) async throws -> Components.Schemas.OrderProductItem {
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
            return item
        case .default(_, let response):
            throw try invalidateLibrarySession(dueTo: response.body.json)
        }
    }

    /// Prepares a download for the given ordered product, requiring an active session.
    ///
    /// Maps to `GET /{api_version}/order_products/{orderProductId}/prepare`. The response
    /// schema is not yet formally defined by the API contract, so it is returned as a raw
    /// JSON object rather than a typed model.
    ///
    /// - Throws: `SDKError.authSession` if the session is missing or the backend rejects the request.
    @discardableResult
    public func prepareDownload(orderProductId: Int) async throws -> OpenAPIObjectContainer {
        _ = try requireSession()
        let config = try requireConfig()
        let client = try requireClient()

        let output = try await client.getDTRPGAPIVERSIONOrderProductsOrderProductIdPrepare(
            .init(path: .init(dtrpgApiVersion: config.apiVersion, orderProductId: orderProductId))
        )

        switch output {
        case .ok(let ok):
            return try ok.body.json
        case .default(_, let response):
            throw try invalidateLibrarySession(dueTo: response.body.json)
        }
    }

    /// Lists the authenticated user's product lists (collections), requiring an active session.
    ///
    /// Maps to `GET /{api_version}/product_lists`.
    ///
    /// - Throws: `SDKError.authSession` if the session is missing or the backend rejects the request.
    @discardableResult
    public func listProductLists(
        _ params: PageParams = .init()
    ) async throws -> Components.Schemas.ProductListCollectionResponse {
        _ = try requireSession()
        let config = try requireConfig()
        let client = try requireClient()

        let output = try await client.getDTRPGAPIVERSIONProductLists(
            .init(
                path: .init(dtrpgApiVersion: config.apiVersion),
                query: .init(page: params.page, pageSize: params.pageSize)
            )
        )

        switch output {
        case .ok(let ok):
            return try ok.body.json
        case .default(_, let response):
            throw try invalidateLibrarySession(dueTo: response.body.json)
        }
    }

    /// Creates a new product list (collection), requiring an active session.
    ///
    /// Maps to `POST /{api_version}/product_lists`.
    ///
    /// - Throws: `SDKError.authSession` if the session is missing or the backend rejects the request.
    @discardableResult
    public func createProductList(name: String) async throws -> Components.Schemas.ProductListAttributes {
        _ = try requireSession()
        let config = try requireConfig()
        let client = try requireClient()

        let output = try await client.postDTRPGAPIVERSIONProductLists(
            .init(
                path: .init(dtrpgApiVersion: config.apiVersion),
                body: .json(.init(name: name))
            )
        )

        switch output {
        case .created(let created):
            return try created.body.json
        case .default(_, let response):
            throw try invalidateLibrarySession(dueTo: response.body.json)
        }
    }

    /// Deletes a product list (collection), requiring an active session.
    ///
    /// Maps to `DELETE /{api_version}/product_lists/{productListId}`.
    ///
    /// - Throws: `SDKError.authSession` if the session is missing or the backend rejects the request.
    public func deleteProductList(productListId: Int) async throws {
        _ = try requireSession()
        let config = try requireConfig()
        let client = try requireClient()

        let output = try await client.deleteDTRPGAPIVERSIONProductListsProductListId(
            .init(path: .init(dtrpgApiVersion: config.apiVersion, productListId: productListId))
        )

        switch output {
        case .noContent:
            return
        case .default(_, let response):
            throw try invalidateLibrarySession(dueTo: response.body.json)
        }
    }

    /// Lists the items within a specific product list, requiring an active session.
    ///
    /// Maps to `GET /{api_version}/product_list_items?productListId={productListId}`. Individual
    /// item schemas are not yet formally defined by the API contract, so items are returned as
    /// raw JSON objects rather than a typed model.
    ///
    /// - Throws: `SDKError.authSession` if the session is missing or the backend rejects the request.
    @discardableResult
    public func listProductListItems(
        productListId: Int,
        params: PageParams = .init()
    ) async throws -> Components.Schemas.PaginatedResponse {
        _ = try requireSession()
        let config = try requireConfig()
        let client = try requireClient()

        let output = try await client.getDTRPGAPIVERSIONProductListItems(
            .init(
                path: .init(dtrpgApiVersion: config.apiVersion),
                query: .init(page: params.page, pageSize: params.pageSize, productListId: productListId)
            )
        )

        switch output {
        case .ok(let ok):
            return try ok.body.json
        case .default(_, let response):
            throw try invalidateLibrarySession(dueTo: response.body.json)
        }
    }

    /// Adds a product to a product list, requiring an active session.
    ///
    /// Maps to `POST /{api_version}/product_list_items`.
    ///
    /// - Throws: `SDKError.authSession` if the session is missing or the backend rejects the request.
    @discardableResult
    public func addProductListItem(
        productId: Int,
        productListId: Int
    ) async throws -> Components.Schemas.ProductListItemCreateResponse {
        _ = try requireSession()
        let config = try requireConfig()
        let client = try requireClient()

        let output = try await client.postDTRPGAPIVERSIONProductListItems(
            .init(
                path: .init(dtrpgApiVersion: config.apiVersion),
                body: .json(.init(productId: productId, productListId: productListId))
            )
        )

        switch output {
        case .created(let created):
            return try created.body.json
        case .default(_, let response):
            throw try invalidateLibrarySession(dueTo: response.body.json)
        }
    }

    /// Removes a product from a product list, requiring an active session.
    ///
    /// Maps to `DELETE /{api_version}/product_list_items/{productListItemId}`.
    ///
    /// - Throws: `SDKError.authSession` if the session is missing or the backend rejects the request.
    public func deleteProductListItem(productListItemId: Int) async throws {
        _ = try requireSession()
        let config = try requireConfig()
        let client = try requireClient()

        let output = try await client.deleteDTRPGAPIVERSIONProductListItemsProductListItemId(
            .init(path: .init(dtrpgApiVersion: config.apiVersion, productListItemId: productListItemId))
        )

        switch output {
        case .noContent:
            return
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
