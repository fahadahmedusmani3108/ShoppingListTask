//
//  MockShoppingDBService.swift
//  MyShoppingTests
//
//  Created by Fahad Ahmed Usmani on 19/05/2025.
//

import Combine
@testable import MyShopping


class MockShoppingDBService: ShoppingDBServiceProtocol {
    var itemsPublisher: AnyPublisher<[ShoppingItemModel], Never> {
        CurrentValueSubject([]).eraseToAnyPublisher()
    }

    func fetchItems() async throws -> [ShoppingItemModel] { [] }
    func saveItem(_ items: [ShoppingItemModel]) async throws {}
    func addItem(_ item: ShoppingItemModel) async throws -> ShoppingItemModel { item }
    func deleteAllItems() async throws {}
    func deleteItem(with id: Int) async throws {}
    func nextSequenceID() throws -> Int64 { 1 }
}
