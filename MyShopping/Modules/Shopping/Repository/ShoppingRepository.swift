//
//  ShoppingRepository.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 12/05/2025.
//

import Combine

protocol ShoppingRepository {
    func getShoppingItems() async throws
    func addShoppingItem(item: ShoppingItemModel) async throws
    func deleteShoppingItem(with id: Int) async throws
    func performBackgroundSync() async
    var itemsPublisher: AnyPublisher<[ShoppingItemModel], Never> { get }
}
