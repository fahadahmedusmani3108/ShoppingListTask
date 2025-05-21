//
//  ShoppingItemRepository.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 13/05/2025.
//

import Combine

class ShoppingItemRepository: ShoppingRepository {
    let dbService: ShoppingDBServiceProtocol
    let networkService: ShoppingNetworkServiceProtocol
    
    var itemsPublisher: AnyPublisher<[ShoppingItemModel], Never> {
        dbService.itemsPublisher
    }
    
    init(dbRepository: ShoppingDBServiceProtocol, networkRepository: ShoppingNetworkServiceProtocol) {
        self.dbService = dbRepository
        self.networkService = networkRepository
    }
    
    func getShoppingItems() async throws {
        let items = try await dbService.fetchItems()
        if items.isEmpty {
            try await dbService.deleteAllItems()
            let items = try await networkService.fetchItems()
            try await dbService.saveItem(items)
        }
    }
    
    func addShoppingItem(item: ShoppingItemModel) async throws {
        let newItem = try await dbService.addItem(item)
        try await networkService.addItem(item: newItem)
    }
    
    func deleteShoppingItem(with id: Int) async throws {
        try await dbService.deleteItem(with: id)
        try await networkService.deleteItem(with: id)
    }
    
    func performBackgroundSync() async {
            do {
                let localItems = try await dbService.fetchItems()
                let remoteItems = try await networkService.fetchItems()
                var latest = [ShoppingItemModel]()
                for remote in remoteItems {
                    if let local = localItems.first(where: { $0.id == remote.id }) {
                        latest.append(remote.modifiedAt > local.modifiedAt ? remote : local)
                    } else {
                        latest.append(remote)
                    }
                }
                try await dbService.saveItem(latest)
                try await networkService.uploadItems(with: latest)
            } catch {
                print("Background sync failed: \(error)")
            }
        }

}
