import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing
@testable import SDK

private func activeSession() -> AuthSession {
    AuthSession(
        token: "jwt",
        refreshToken: "refresh",
        refreshTokenExpiresAt: Date(timeIntervalSince1970: 1_800_000_000)
    )
}

private func sessionErrorExpectation(_ authState: AuthState, message: String) -> SDKError {
    .authSession(.init(errorCode: authState.rawValue, message: message, authState: authState))
}

private func orderProductItem(
    orderProductId: Int = 174_269_090,
    name: String = "Sandbox Generator"
) -> Components.Schemas.OrderProductItem {
    .init(
        id: "/api/vBeta/order_products/\(orderProductId)",
        _type: .orderProduct,
        attributes: .init(
            orderId: 49_674_203,
            productId: 430_675,
            royaltyPublisherId: 12_407,
            name: name,
            finalPrice: 12,
            quantity: 1,
            bundleId: 0,
            archived: 0,
            orderProductId: orderProductId,
            customerId: 399_144,
            files: [
                .init(
                    index: 0,
                    orderProductDownloadId: 167_421_777,
                    title: "Sandbox_Generator.pdf",
                    filename: "Sandbox_Generator.pdf",
                    size: 5_894_763,
                    sizeMB: "5.89",
                    checksums: []
                )
            ]
        )
    )
}

private func productListAttributes(
    productListId: Int = 1498,
    name: String = "Maps"
) -> Components.Schemas.ProductListAttributes {
    .init(
        customerId: 399_144,
        name: name,
        dateCreated: Date(timeIntervalSince1970: 1_655_954_725),
        productListId: productListId,
        slug: "maps",
        itemCount: 359
    )
}

// MARK: - listOrderProducts

@Test func listOrderProductsRequiresSession() async throws {
    let sdk = SDK(
        client: LibraryClientStub(orderProductsOutput: .successOutput()),
        config: Config(apiKey: "app-key")
    )

    await #expect(throws: sessionErrorExpectation(
        .unauthenticated,
        message: "SDK does not have an authenticated session."
    )) {
        try await sdk.listOrderProducts()
    }
}

@Test func listOrderProductsBuildsGeneratedInputAndReturnsResponse() async throws {
    let client = LibraryClientStub(orderProductsOutput: .successOutput())
    let sdk = SDK(
        client: client,
        config: Config(apiKey: "app-key", apiVersion: "vTest"),
        session: activeSession()
    )

    let response = try await sdk.listOrderProducts(
        LibraryItemsParams(page: 2, pageSize: 25, library: true)
    )

    #expect(client.orderProductsInput?.path.dtrpgApiVersion == "vTest")
    #expect(client.orderProductsInput?.query.page == 2)
    #expect(client.orderProductsInput?.query.pageSize == 25)
    #expect(client.orderProductsInput?.query.library == true)
    #expect(response.meta.currentPage == 1)
    #expect(response.data.count == 1)
    #expect(response.data[0].attributes.orderProductId == 174_269_090)
}

@Test func listOrderProductsInvalidatesSessionOnFailure() async throws {
    let apiError = Components.Schemas.AuthSessionError(
        errorCode: AuthState.tokenExpired.rawValue,
        message: "Token expired.",
        authState: .tokenExpired
    )
    let sdk = SDK(
        client: LibraryClientStub(orderProductsOutput: .default(statusCode: 401, .init(body: .json(apiError)))),
        config: Config(apiKey: "app-key"),
        session: activeSession()
    )

    await #expect(throws: sessionErrorExpectation(.tokenExpired, message: "Token expired.")) {
        try await sdk.listOrderProducts()
    }
    #expect(sdk.session == nil)
}

// MARK: - getOrderProduct

@Test func getOrderProductRequiresSession() async throws {
    let sdk = SDK(
        client: LibraryClientStub(orderProductDetailOutput: .successOutput()),
        config: Config(apiKey: "app-key")
    )

    await #expect(throws: sessionErrorExpectation(
        .unauthenticated,
        message: "SDK does not have an authenticated session."
    )) {
        try await sdk.getOrderProduct(orderProductId: 174_269_090)
    }
}

@Test func getOrderProductReturnsGeneratedItem() async throws {
    let client = LibraryClientStub(orderProductDetailOutput: .successOutput())
    let sdk = SDK(
        client: client,
        config: Config(apiKey: "app-key", apiVersion: "vTest"),
        session: activeSession()
    )

    let item = try await sdk.getOrderProduct(orderProductId: 174_269_090)

    #expect(client.orderProductDetailInput?.path.dtrpgApiVersion == "vTest")
    #expect(client.orderProductDetailInput?.path.orderProductId == 174_269_090)
    #expect(item.attributes.orderProductId == 174_269_090)
    #expect(item.attributes.name == "Sandbox Generator")
}

@Test func getOrderProductThrowsNotFoundWhenDataMissing() async throws {
    let sdk = SDK(
        client: LibraryClientStub(orderProductDetailOutput: .ok(.init(body: .json(.init(data: nil))))),
        config: Config(apiKey: "app-key"),
        session: activeSession()
    )

    await #expect(throws: SDKError.libraryItemNotFound(orderProductId: 174_269_090)) {
        try await sdk.getOrderProduct(orderProductId: 174_269_090)
    }
}

@Test func getOrderProductInvalidatesSessionOnFailure() async throws {
    let apiError = Components.Schemas.AuthSessionError(
        errorCode: AuthState.refreshExpired.rawValue,
        message: "Refresh token expired.",
        authState: .refreshExpired
    )
    let sdk = SDK(
        client: LibraryClientStub(
            orderProductDetailOutput: .default(statusCode: 401, .init(body: .json(apiError)))
        ),
        config: Config(apiKey: "app-key"),
        session: activeSession()
    )

    await #expect(throws: sessionErrorExpectation(.refreshExpired, message: "Refresh token expired.")) {
        try await sdk.getOrderProduct(orderProductId: 174_269_090)
    }
    #expect(sdk.session == nil)
}

// MARK: - prepareDownload

@Test func prepareDownloadRequiresSession() async throws {
    let sdk = SDK(
        client: LibraryClientStub(prepareOutput: .successOutput()),
        config: Config(apiKey: "app-key")
    )

    await #expect(throws: sessionErrorExpectation(
        .unauthenticated,
        message: "SDK does not have an authenticated session."
    )) {
        try await sdk.prepareDownload(orderProductId: 174_269_090)
    }
}

@Test func prepareDownloadBuildsGeneratedInput() async throws {
    let client = LibraryClientStub(prepareOutput: .successOutput())
    let sdk = SDK(
        client: client,
        config: Config(apiKey: "app-key", apiVersion: "vTest"),
        session: activeSession()
    )

    _ = try await sdk.prepareDownload(orderProductId: 174_269_090)

    #expect(client.prepareInput?.path.dtrpgApiVersion == "vTest")
    #expect(client.prepareInput?.path.orderProductId == 174_269_090)
}

// MARK: - listProductLists

@Test func listProductListsRequiresSession() async throws {
    let sdk = SDK(
        client: LibraryClientStub(productListsOutput: .successOutput()),
        config: Config(apiKey: "app-key")
    )

    await #expect(throws: sessionErrorExpectation(
        .unauthenticated,
        message: "SDK does not have an authenticated session."
    )) {
        try await sdk.listProductLists()
    }
}

@Test func listProductListsBuildsGeneratedInputAndReturnsResponse() async throws {
    let client = LibraryClientStub(productListsOutput: .successOutput())
    let sdk = SDK(
        client: client,
        config: Config(apiKey: "app-key", apiVersion: "vTest"),
        session: activeSession()
    )

    let response = try await sdk.listProductLists(PageParams(page: 1, pageSize: 50))

    #expect(client.productListsInput?.path.dtrpgApiVersion == "vTest")
    #expect(client.productListsInput?.query.page == 1)
    #expect(response.data.count == 1)
    #expect(response.data[0].attributes.productListId == 1498)
}

// MARK: - createProductList

@Test func createProductListRequiresSession() async throws {
    let sdk = SDK(
        client: LibraryClientStub(createProductListOutput: .successOutput()),
        config: Config(apiKey: "app-key")
    )

    await #expect(throws: sessionErrorExpectation(
        .unauthenticated,
        message: "SDK does not have an authenticated session."
    )) {
        try await sdk.createProductList(name: "Maps")
    }
}

@Test func createProductListSendsNameAndReturnsAttributes() async throws {
    let client = LibraryClientStub(createProductListOutput: .successOutput())
    let sdk = SDK(
        client: client,
        config: Config(apiKey: "app-key", apiVersion: "vTest"),
        session: activeSession()
    )

    let attributes = try await sdk.createProductList(name: "Maps")

    #expect(client.createProductListInput?.body == .json(.init(name: "Maps")))
    #expect(attributes.productListId == 1498)
}

// MARK: - deleteProductList

@Test func deleteProductListRequiresSession() async throws {
    let sdk = SDK(
        client: LibraryClientStub(deleteProductListOutput: .noContent),
        config: Config(apiKey: "app-key")
    )

    await #expect(throws: sessionErrorExpectation(
        .unauthenticated,
        message: "SDK does not have an authenticated session."
    )) {
        try await sdk.deleteProductList(productListId: 1498)
    }
}

@Test func deleteProductListBuildsGeneratedInput() async throws {
    let client = LibraryClientStub(deleteProductListOutput: .noContent)
    let sdk = SDK(
        client: client,
        config: Config(apiKey: "app-key", apiVersion: "vTest"),
        session: activeSession()
    )

    try await sdk.deleteProductList(productListId: 1498)

    #expect(client.deleteProductListInput?.path.dtrpgApiVersion == "vTest")
    #expect(client.deleteProductListInput?.path.productListId == 1498)
}

// MARK: - listProductListItems

@Test func listProductListItemsRequiresSession() async throws {
    let sdk = SDK(
        client: LibraryClientStub(productListItemsOutput: .successOutput()),
        config: Config(apiKey: "app-key")
    )

    await #expect(throws: sessionErrorExpectation(
        .unauthenticated,
        message: "SDK does not have an authenticated session."
    )) {
        try await sdk.listProductListItems(productListId: 1498)
    }
}

@Test func listProductListItemsBuildsGeneratedInput() async throws {
    let client = LibraryClientStub(productListItemsOutput: .successOutput())
    let sdk = SDK(
        client: client,
        config: Config(apiKey: "app-key", apiVersion: "vTest"),
        session: activeSession()
    )

    _ = try await sdk.listProductListItems(productListId: 1498, params: PageParams(page: 1, pageSize: 50))

    #expect(client.productListItemsInput?.query.productListId == 1498)
    #expect(client.productListItemsInput?.query.page == 1)
}

// MARK: - addProductListItem

@Test func addProductListItemRequiresSession() async throws {
    let sdk = SDK(
        client: LibraryClientStub(addProductListItemOutput: .successOutput()),
        config: Config(apiKey: "app-key")
    )

    await #expect(throws: sessionErrorExpectation(
        .unauthenticated,
        message: "SDK does not have an authenticated session."
    )) {
        try await sdk.addProductListItem(productId: 430_675, productListId: 1498)
    }
}

@Test func addProductListItemSendsBodyAndReturnsResponse() async throws {
    let client = LibraryClientStub(addProductListItemOutput: .successOutput())
    let sdk = SDK(
        client: client,
        config: Config(apiKey: "app-key", apiVersion: "vTest"),
        session: activeSession()
    )

    let response = try await sdk.addProductListItem(productId: 430_675, productListId: 1498)

    #expect(client.addProductListItemInput?.body == .json(.init(productId: 430_675, productListId: 1498)))
    #expect(response.productListItemId == 2_629_322)
}

// MARK: - deleteProductListItem

@Test func deleteProductListItemRequiresSession() async throws {
    let sdk = SDK(
        client: LibraryClientStub(deleteProductListItemOutput: .noContent),
        config: Config(apiKey: "app-key")
    )

    await #expect(throws: sessionErrorExpectation(
        .unauthenticated,
        message: "SDK does not have an authenticated session."
    )) {
        try await sdk.deleteProductListItem(productListItemId: 2_629_322)
    }
}

@Test func deleteProductListItemBuildsGeneratedInput() async throws {
    let client = LibraryClientStub(deleteProductListItemOutput: .noContent)
    let sdk = SDK(
        client: client,
        config: Config(apiKey: "app-key", apiVersion: "vTest"),
        session: activeSession()
    )

    try await sdk.deleteProductListItem(productListItemId: 2_629_322)

    #expect(client.deleteProductListItemInput?.path.productListItemId == 2_629_322)
}

// MARK: - Bearer token middleware

@Test func bearerTokenMiddlewareAttachesAuthorizationHeaderWhenSessionPresent() async throws {
    let middleware = BearerTokenMiddleware(tokenProvider: { "jwt-token" })
    let capture = RequestCapture()

    _ = try await middleware.intercept(
        HTTPRequest(method: .get, scheme: "https", authority: "example.test", path: "/order_products"),
        body: nil,
        baseURL: URL(string: "https://example.test")!,
        operationID: "test"
    ) { request, body, _ in
        capture.request = request
        return (HTTPResponse(status: .ok), body)
    }

    #expect(capture.request?.headerFields[.authorization] == "Bearer jwt-token")
}

@Test func bearerTokenMiddlewareOmitsHeaderWhenNoSession() async throws {
    let middleware = BearerTokenMiddleware(tokenProvider: { nil })
    let capture = RequestCapture()

    _ = try await middleware.intercept(
        HTTPRequest(method: .get, scheme: "https", authority: "example.test", path: "/order_products"),
        body: nil,
        baseURL: URL(string: "https://example.test")!,
        operationID: "test"
    ) { request, body, _ in
        capture.request = request
        return (HTTPResponse(status: .ok), body)
    }

    #expect(capture.request?.headerFields[.authorization] == nil)
}

private final class RequestCapture: @unchecked Sendable {
    var request: HTTPRequest?
}

// MARK: - Stub client

final class LibraryClientStub: APIProtocol, @unchecked Sendable {
    var orderProductsInput: Operations.GetDTRPGAPIVERSIONOrderProducts.Input?
    var orderProductDetailInput: Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductId.Input?
    var prepareInput: Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductIdPrepare.Input?
    var productListsInput: Operations.GetDTRPGAPIVERSIONProductLists.Input?
    var createProductListInput: Operations.PostDTRPGAPIVERSIONProductLists.Input?
    var deleteProductListInput: Operations.DeleteDTRPGAPIVERSIONProductListsProductListId.Input?
    var productListItemsInput: Operations.GetDTRPGAPIVERSIONProductListItems.Input?
    var addProductListItemInput: Operations.PostDTRPGAPIVERSIONProductListItems.Input?
    var deleteProductListItemInput: Operations.DeleteDTRPGAPIVERSIONProductListItemsProductListItemId.Input?

    let orderProductsOutput: Operations.GetDTRPGAPIVERSIONOrderProducts.Output
    let orderProductDetailOutput: Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductId.Output
    let prepareOutput: Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductIdPrepare.Output
    let productListsOutput: Operations.GetDTRPGAPIVERSIONProductLists.Output
    let createProductListOutput: Operations.PostDTRPGAPIVERSIONProductLists.Output
    let deleteProductListOutput: Operations.DeleteDTRPGAPIVERSIONProductListsProductListId.Output
    let productListItemsOutput: Operations.GetDTRPGAPIVERSIONProductListItems.Output
    let addProductListItemOutput: Operations.PostDTRPGAPIVERSIONProductListItems.Output
    let deleteProductListItemOutput: Operations.DeleteDTRPGAPIVERSIONProductListItemsProductListItemId.Output

    init(
        orderProductsOutput: Operations.GetDTRPGAPIVERSIONOrderProducts.Output = .successOutput(),
        orderProductDetailOutput: Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductId.Output = .successOutput(),
        prepareOutput: Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductIdPrepare.Output = .successOutput(),
        productListsOutput: Operations.GetDTRPGAPIVERSIONProductLists.Output = .successOutput(),
        createProductListOutput: Operations.PostDTRPGAPIVERSIONProductLists.Output = .successOutput(),
        deleteProductListOutput: Operations.DeleteDTRPGAPIVERSIONProductListsProductListId.Output = .noContent,
        productListItemsOutput: Operations.GetDTRPGAPIVERSIONProductListItems.Output = .successOutput(),
        addProductListItemOutput: Operations.PostDTRPGAPIVERSIONProductListItems.Output = .successOutput(),
        deleteProductListItemOutput: Operations.DeleteDTRPGAPIVERSIONProductListItemsProductListItemId.Output = .noContent
    ) {
        self.orderProductsOutput = orderProductsOutput
        self.orderProductDetailOutput = orderProductDetailOutput
        self.prepareOutput = prepareOutput
        self.productListsOutput = productListsOutput
        self.createProductListOutput = createProductListOutput
        self.deleteProductListOutput = deleteProductListOutput
        self.productListItemsOutput = productListItemsOutput
        self.addProductListItemOutput = addProductListItemOutput
        self.deleteProductListItemOutput = deleteProductListItemOutput
    }

    func postDTRPGAPIVERSIONAuthKey(
        _ input: Operations.PostDTRPGAPIVERSIONAuthKey.Input
    ) async throws -> Operations.PostDTRPGAPIVERSIONAuthKey.Output {
        fatalError("Not used by library tests")
    }

    func getDTRPGAPIVERSIONOrderProducts(
        _ input: Operations.GetDTRPGAPIVERSIONOrderProducts.Input
    ) async throws -> Operations.GetDTRPGAPIVERSIONOrderProducts.Output {
        orderProductsInput = input
        return orderProductsOutput
    }

    func getDTRPGAPIVERSIONOrderProductsOrderProductId(
        _ input: Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductId.Input
    ) async throws -> Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductId.Output {
        orderProductDetailInput = input
        return orderProductDetailOutput
    }

    func getDTRPGAPIVERSIONOrderProductsOrderProductIdPrepare(
        _ input: Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductIdPrepare.Input
    ) async throws -> Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductIdPrepare.Output {
        prepareInput = input
        return prepareOutput
    }

    func getDTRPGAPIVERSIONProductLists(
        _ input: Operations.GetDTRPGAPIVERSIONProductLists.Input
    ) async throws -> Operations.GetDTRPGAPIVERSIONProductLists.Output {
        productListsInput = input
        return productListsOutput
    }

    func postDTRPGAPIVERSIONProductLists(
        _ input: Operations.PostDTRPGAPIVERSIONProductLists.Input
    ) async throws -> Operations.PostDTRPGAPIVERSIONProductLists.Output {
        createProductListInput = input
        return createProductListOutput
    }

    func deleteDTRPGAPIVERSIONProductListsProductListId(
        _ input: Operations.DeleteDTRPGAPIVERSIONProductListsProductListId.Input
    ) async throws -> Operations.DeleteDTRPGAPIVERSIONProductListsProductListId.Output {
        deleteProductListInput = input
        return deleteProductListOutput
    }

    func getDTRPGAPIVERSIONProductListItems(
        _ input: Operations.GetDTRPGAPIVERSIONProductListItems.Input
    ) async throws -> Operations.GetDTRPGAPIVERSIONProductListItems.Output {
        productListItemsInput = input
        return productListItemsOutput
    }

    func postDTRPGAPIVERSIONProductListItems(
        _ input: Operations.PostDTRPGAPIVERSIONProductListItems.Input
    ) async throws -> Operations.PostDTRPGAPIVERSIONProductListItems.Output {
        addProductListItemInput = input
        return addProductListItemOutput
    }

    func deleteDTRPGAPIVERSIONProductListItemsProductListItemId(
        _ input: Operations.DeleteDTRPGAPIVERSIONProductListItemsProductListItemId.Input
    ) async throws -> Operations.DeleteDTRPGAPIVERSIONProductListItemsProductListItemId.Output {
        deleteProductListItemInput = input
        return deleteProductListItemOutput
    }
}

private extension Operations.GetDTRPGAPIVERSIONOrderProducts.Output {
    static func successOutput() -> Self {
        .ok(.init(body: .json(.init(
            links: .init(_self: "/api/vBeta/order_products?page=1"),
            meta: .init(itemsPerPage: 50, currentPage: 1),
            data: [orderProductItem()]
        ))))
    }
}

private extension Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductId.Output {
    static func successOutput() -> Self {
        .ok(.init(body: .json(.init(data: orderProductItem()))))
    }
}

private extension Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductIdPrepare.Output {
    static func successOutput() -> Self {
        .ok(.init(body: .json(try! .init(unvalidatedValue: ["downloadUrl": "https://example.test/file.pdf"]))))
    }
}

private extension Operations.GetDTRPGAPIVERSIONProductLists.Output {
    static func successOutput() -> Self {
        .ok(.init(body: .json(.init(
            links: .init(_self: "/api/vBeta/product_lists?page=1"),
            meta: .init(itemsPerPage: 50, currentPage: 1),
            data: [.init(id: "/api/vBeta/product_lists/1498", _type: .productList, attributes: productListAttributes())]
        ))))
    }
}

private extension Operations.PostDTRPGAPIVERSIONProductLists.Output {
    static func successOutput() -> Self {
        .created(.init(body: .json(productListAttributes())))
    }
}

private extension Operations.GetDTRPGAPIVERSIONProductListItems.Output {
    static func successOutput() -> Self {
        .ok(.init(body: .json(.init(
            links: .init(_self: "/api/vBeta/product_list_items?productListId=1498&page=1"),
            meta: .init(itemsPerPage: 50, currentPage: 1),
            data: []
        ))))
    }
}

private extension Operations.PostDTRPGAPIVERSIONProductListItems.Output {
    static func successOutput() -> Self {
        .created(.init(body: .json(.init(
            productId: 430_675,
            productListId: 1498,
            productListItemId: 2_629_322
        ))))
    }
}
