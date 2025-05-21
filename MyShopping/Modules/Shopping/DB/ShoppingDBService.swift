//
//  ShoppingDBService.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 13/05/2025.
//

import CoreData
import Combine

class ShoppingDBService: ShoppingDBServiceProtocol {
    private let context: NSManagedObjectContext = CoreDataManager.shared.context
    private let itemsSubject = CurrentValueSubject<[ShoppingItemModel], Never>([])

    var itemsPublisher: AnyPublisher<[ShoppingItemModel], Never> {
        itemsSubject.eraseToAnyPublisher()
    }

    func fetchItems() async throws -> [ShoppingItemModel] {
        let fetchRequest: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
        let items = try context.fetch(fetchRequest)
        let shoppingItems = items.map { ShoppingItemModel(coreDataItem: $0) }
        itemsSubject.send(shoppingItems)
        return shoppingItems
    }

    func saveItem(_ items: [ShoppingItemModel]) async throws {
        try items.forEach({
            let fetchRequest: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %lld", $0.id as CVarArg)
            fetchRequest.fetchLimit = 1
            
            let existingTasks = try context.fetch(fetchRequest)
            let newItem: ShoppingItem
            
            if let existing = existingTasks.first {
                // Update existing task
                newItem = existing
            } else {
                // Create new task
                newItem = ShoppingItem(context: context)
                newItem.id = $0.id > 0 ? Int64($0.id) : try nextSequenceID()
            }
            newItem.title = $0.title
            newItem.notes = $0.notes
            newItem.isBought = $0.isBought
            newItem.createdAt = $0.createdAt
            newItem.modifiedAt = $0.modifiedAt
            newItem.quantity = Int16($0.quantity)
        })
        try context.save()
        _ = try await fetchItems()
    }

    func addItem(_ item: ShoppingItemModel) async throws -> ShoppingItemModel {
        let fetchRequest: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %lld", item.id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        let existingTasks = try context.fetch(fetchRequest)
        let newItem: ShoppingItem
        
        if let existing = existingTasks.first {
            newItem = existing
        } else {
            newItem = ShoppingItem(context: context)
            newItem.id = try nextSequenceID()
        }
        newItem.title = item.title
        newItem.notes = item.notes
        newItem.isBought = item.isBought
        newItem.createdAt = item.createdAt
        newItem.modifiedAt = item.modifiedAt
        newItem.quantity = Int16(item.quantity)
        try context.save()
        _ = try await fetchItems()
        return ShoppingItemModel(coreDataItem: newItem)
    }

    func deleteItem(with id: Int) async throws {
        let fetchRequest: NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %lld", Int64(id))
        let items = try context.fetch(fetchRequest)
        items.forEach({ context.delete($0) })
        try context.save()
        _ = try await fetchItems()
    }

    func deleteAllItems() async throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ShoppingItem.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        try context.save()
        itemsSubject.send([])
    }

    func nextSequenceID() throws -> Int64 {
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "ShoppingItem")
        fetchRequest.resultType = .dictionaryResultType
        
        let expression = NSExpression(forFunction: "max:", arguments: [NSExpression(forKeyPath: "id")])
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "maxID"
        expressionDescription.expression = expression
        expressionDescription.expressionResultType = .integer64AttributeType
        fetchRequest.propertiesToFetch = [expressionDescription]
        
        let results = try context.fetch(fetchRequest)
        let maxID = results.first?["maxID"] as? Int64 ?? 0
        return maxID + 1
    }
}
