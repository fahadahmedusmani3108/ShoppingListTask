//
//  ShoppingItemModel.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 07/05/2025.
//

import CoreData

struct ShoppingItemModel: Codable {
    let id: Int
    let title: String
    let quantity: Int
    let notes: String
    var isBought: Bool
    let createdAt: String
    let modifiedAt: String
}

extension ShoppingItemModel {
    init(coreDataItem: ShoppingItem) {
        self.id = Int(coreDataItem.id)
        self.title = coreDataItem.title ?? ""
        self.quantity = Int(coreDataItem.quantity)
        self.notes = coreDataItem.notes ?? ""
        self.isBought = coreDataItem.isBought
        self.createdAt = coreDataItem.createdAt ?? ""
        self.modifiedAt = coreDataItem.modifiedAt ?? ""
    }
}
