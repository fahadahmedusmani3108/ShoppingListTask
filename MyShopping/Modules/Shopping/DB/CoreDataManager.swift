//
//  CoreDataManager.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 14/05/2025.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }
    
    private init() {
        guard let modelURL = Bundle(for: CoreDataManager.self).url(forResource: "ShoppingDB", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load Core Data model from bundle")
        }

        container = NSPersistentContainer(name: "ShoppingDB", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error loading persistent store: \(error)")
            }
        }
    }
}
