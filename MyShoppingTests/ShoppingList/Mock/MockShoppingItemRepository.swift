//
//  MockShoppingItemRepository.swift
//  MyShoppingTests
//
//  Created by Fahad Ahmed Usmani on 17/05/2025.
//

import Combine
@testable import MyShopping

class MockShoppingItemRepository: ShoppingRepository {
    var shouldThrowError = false
    var didCallDelete = false
    var didCallAdd = false
    private let itemsSubject: CurrentValueSubject<[ShoppingItemModel], Never>
    var itemsPublisher: AnyPublisher<[ShoppingItemModel], Never> {
        itemsSubject.eraseToAnyPublisher()
    }

    var mockItems: [ShoppingItemModel] = [] {
        didSet {
            itemsSubject.send(mockItems)
        }
    }

    init() {
        itemsSubject = CurrentValueSubject([])
    }

    func getShoppingItems() async throws {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }
    }

    func addShoppingItem(item: ShoppingItemModel) async throws {
        didCallAdd = true
        mockItems.append(item)
    }

    func deleteShoppingItem(with id: Int) async throws {
        didCallDelete = true
        mockItems.removeAll { $0.id == id }
    }

    func performBackgroundSync() async {
        // Mock implementation
    }
}
