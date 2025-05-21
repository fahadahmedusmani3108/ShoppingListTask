//
//  ShoppingDBServiceProtocol.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 14/05/2025.
//

import Combine

protocol ShoppingDBServiceProtocol {
    func fetchItems() async throws -> [ShoppingItemModel]
    func saveItem(_ items: [ShoppingItemModel]) async throws
    func addItem(_ item: ShoppingItemModel) async throws -> ShoppingItemModel
    func deleteAllItems() async throws
    func deleteItem(with id: Int) async throws
    func nextSequenceID() throws -> Int64
    var itemsPublisher: AnyPublisher<[ShoppingItemModel], Never> { get }
}
