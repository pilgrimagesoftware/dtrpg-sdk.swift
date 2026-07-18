import Foundation
import Testing
@testable import SDK

private func activeSession() -> AuthSession {
    AuthSession(
        token: "jwt",
        refreshToken: "refresh",
        refreshTokenExpiresAt: Date(timeIntervalSince1970: 1_800_000_000)
    )
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

@Test func listLibraryItemsRequiresSession() async throws {
    let sdk = SDK(
        client: LibraryClientStub(orderProductsOutput: .successOutput()),
        config: Config(apiKey: "app-key")
    )

    await #expect(throws: SDKError.authSession(.init(
        errorCode: AuthState.unauthenticated.rawValue,
        message: "SDK does not have an authenticated session.",
        authState: .unauthenticated
    ))) {
        try await sdk.listLibraryItems()
    }
}

@Test func listLibraryItemsBuildsGeneratedInputAndReturnsPage() async throws {
    let client = LibraryClientStub(orderProductsOutput: .successOutput())
    let sdk = SDK(
        client: client,
        config: Config(apiKey: "app-key", apiVersion: "vTest"),
        session: activeSession()
    )

    let page = try await sdk.listLibraryItems(page: 2, pageSize: 25)

    #expect(client.orderProductsInput?.path.dtrpgApiVersion == "vTest")
    #expect(client.orderProductsInput?.query.page == 2)
    #expect(client.orderProductsInput?.query.pageSize == 25)
    #expect(client.orderProductsInput?.query.library == true)
    #expect(page.currentPage == 1)
    #expect(page.itemsPerPage == 50)
    #expect(page.items.count == 1)
    #expect(page.items[0].orderProductId == 174_269_090)
    #expect(page.items[0].name == "Sandbox Generator")
    #expect(page.items[0].files.first?.filename == "Sandbox_Generator.pdf")
}

@Test func listLibraryItemsInvalidatesSessionOnFailure() async throws {
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

    await #expect(throws: SDKError.authSession(.init(
        errorCode: AuthState.tokenExpired.rawValue,
        message: "Token expired.",
        authState: .tokenExpired
    ))) {
        try await sdk.listLibraryItems()
    }
    #expect(sdk.session == nil)
}

@Test func libraryItemDetailRequiresSession() async throws {
    let sdk = SDK(
        client: LibraryClientStub(orderProductDetailOutput: .successOutput()),
        config: Config(apiKey: "app-key")
    )

    await #expect(throws: SDKError.authSession(.init(
        errorCode: AuthState.unauthenticated.rawValue,
        message: "SDK does not have an authenticated session.",
        authState: .unauthenticated
    ))) {
        try await sdk.libraryItemDetail(orderProductId: 174_269_090)
    }
}

@Test func libraryItemDetailReturnsMappedItem() async throws {
    let client = LibraryClientStub(orderProductDetailOutput: .successOutput())
    let sdk = SDK(
        client: client,
        config: Config(apiKey: "app-key", apiVersion: "vTest"),
        session: activeSession()
    )

    let item = try await sdk.libraryItemDetail(orderProductId: 174_269_090)

    #expect(client.orderProductDetailInput?.path.dtrpgApiVersion == "vTest")
    #expect(client.orderProductDetailInput?.path.orderProductId == 174_269_090)
    #expect(item.orderProductId == 174_269_090)
    #expect(item.name == "Sandbox Generator")
}

@Test func libraryItemDetailThrowsNotFoundWhenDataMissing() async throws {
    let sdk = SDK(
        client: LibraryClientStub(orderProductDetailOutput: .ok(.init(body: .json(.init(data: nil))))),
        config: Config(apiKey: "app-key"),
        session: activeSession()
    )

    await #expect(throws: SDKError.libraryItemNotFound(orderProductId: 174_269_090)) {
        try await sdk.libraryItemDetail(orderProductId: 174_269_090)
    }
}

@Test func libraryItemDetailInvalidatesSessionOnFailure() async throws {
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

    await #expect(throws: SDKError.authSession(.init(
        errorCode: AuthState.refreshExpired.rawValue,
        message: "Refresh token expired.",
        authState: .refreshExpired
    ))) {
        try await sdk.libraryItemDetail(orderProductId: 174_269_090)
    }
    #expect(sdk.session == nil)
}

final class LibraryClientStub: APIProtocol, @unchecked Sendable {
    var orderProductsInput: Operations.GetDTRPGAPIVERSIONOrderProducts.Input?
    var orderProductDetailInput: Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductId.Input?
    let orderProductsOutput: Operations.GetDTRPGAPIVERSIONOrderProducts.Output
    let orderProductDetailOutput: Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductId.Output

    init(
        orderProductsOutput: Operations.GetDTRPGAPIVERSIONOrderProducts.Output = .successOutput(),
        orderProductDetailOutput: Operations.GetDTRPGAPIVERSIONOrderProductsOrderProductId.Output = .successOutput()
    ) {
        self.orderProductsOutput = orderProductsOutput
        self.orderProductDetailOutput = orderProductDetailOutput
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
        fatalError("Not used by library tests")
    }

    func getDTRPGAPIVERSIONProductLists(
        _ input: Operations.GetDTRPGAPIVERSIONProductLists.Input
    ) async throws -> Operations.GetDTRPGAPIVERSIONProductLists.Output {
        fatalError("Not used by library tests")
    }

    func getDTRPGAPIVERSIONProductListItems(
        _ input: Operations.GetDTRPGAPIVERSIONProductListItems.Input
    ) async throws -> Operations.GetDTRPGAPIVERSIONProductListItems.Output {
        fatalError("Not used by library tests")
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
