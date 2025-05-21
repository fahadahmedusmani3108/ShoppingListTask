//
//  ShoppingNetworkServiceProtocol.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 14/05/2025.
//

import Foundation

protocol ShoppingNetworkServiceProtocol {
    func fetchItems() async throws -> [ShoppingItemModel]
    func addItem(item: ShoppingItemModel) async throws
    func deleteItem(with id: Int) async throws
    func uploadItems(with items: [ShoppingItemModel]) async throws
}
