//
//  ShoppingNetworkService.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 13/05/2025.
//

import Combine

final class ShoppingNetworkService: ShoppingNetworkServiceProtocol {

    func fetchItems() async throws -> [ShoppingItemModel] {
        // Simulate network call
        try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate network delay
        return try loadJSON()
    }
    
    func addItem(item: ShoppingItemModel) async throws {
        var items = try loadJSON()
        items.append(item)
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docsURL.appendingPathComponent("MockShoppingData.json")
        let data = try JSONEncoder().encode(items)
        try data.write(to: fileURL)
    }
    
    func deleteItem(with id: Int) async throws {
        var items = try loadJSON()
        items.removeAll { $0.id == id }
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docsURL.appendingPathComponent("MockShoppingData.json")
        let data = try JSONEncoder().encode(items)
        try data.write(to: fileURL)
    }
    
    func uploadItems(with items: [ShoppingItemModel]) async throws {
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docsURL.appendingPathComponent("MockShoppingData.json")
        let data = try JSONEncoder().encode(items)
        try data.write(to: fileURL)
    }
}

private extension ShoppingNetworkService {
    func loadJSON() throws -> [ShoppingItemModel] {
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = docsURL.appendingPathComponent("MockShoppingData.json")

            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: fileURL.path) {
                // Copy from bundle to documents directory
                guard let bundleURL = Bundle.init(for: ShoppingNetworkService.self).url(forResource: "MockShoppingData", withExtension: "json") else {
                    throw NSError(domain: "FileNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "MockShoppingData.json not found in bundle"])
                }
                try fileManager.copyItem(at: bundleURL, to: fileURL)
            }
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([ShoppingItemModel].self, from: data)
    }
}
