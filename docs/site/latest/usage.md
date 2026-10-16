---
title: Usage examples
version: latest
slug: usage
---

# Usage examples

All library operations below require an active session from `authenticate()`. The SDK invalidates
the session automatically and throws `SDKError.authSession` if the backend rejects a request.

## Listing a user's library

```swift
let params = LibraryItemsParams(page: 1, pageSize: 50, library: true)
let response = try await sdk.listOrderProducts(params)
```

## Fetching a single ordered product

```swift
let item = try await sdk.getOrderProduct(orderProductId: 12345)
```

## Preparing a download

```swift
let download = try await sdk.prepareDownload(orderProductId: 12345)
```

## Managing collections (product lists)

```swift
// List collections
let lists = try await sdk.listProductLists(PageParams(page: 1, pageSize: 20))

// Create a collection
let created = try await sdk.createProductList(name: "My Campaign")

// List items in a collection
let items = try await sdk.listProductListItems(productListId: created.id, params: PageParams())

// Add a product to a collection
try await sdk.addProductListItem(productId: 67890, productListId: created.id)

// Remove a product from a collection
try await sdk.deleteProductListItem(productListItemId: 1)

// Delete a collection
try await sdk.deleteProductList(productListId: created.id)
```

## Handling errors

```swift
do {
    let library = try await sdk.listOrderProducts()
} catch SDKError.authSession(let sessionError) {
    // Session was invalidated by the backend; re-authenticate.
} catch SDKError.libraryItemNotFound(let orderProductId) {
    // The requested item has no associated data.
} catch {
    // Other SDK or transport errors.
}
```
