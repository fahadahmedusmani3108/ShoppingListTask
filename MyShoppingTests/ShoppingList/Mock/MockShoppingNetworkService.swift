//
//  MockShoppingNetworkService.swift
//  MyShoppingTests
//
//  Created by Fahad Ahmed Usmani on 19/05/2025.
//

@testable import MyShopping

class MockShoppingNetworkService: ShoppingNetworkServiceProtocol {
    var mockItems: [ShoppingItemModel] = []
    var shouldThrowError = false
    
    func fetchItems() async throws -> [ShoppingItemModel] {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }
        return mockItems
    }
    
    func addItem(item: ShoppingItemModel) async throws {
        mockItems.append(item)
    }
    
    func deleteItem(with id: Int) async throws {
        mockItems.removeAll { $0.id == id }
    }
    
    func uploadItems(with items: [ShoppingItemModel]) async throws {
        mockItems = items
    }
}
