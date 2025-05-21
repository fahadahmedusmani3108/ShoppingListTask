//
//  ShoppingListQuickAction.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 09/05/2025.
//

import Foundation

enum ShoppingListQuickAction: CaseIterable {
    case edit
    case delete
    case markAsBought
    
    var actionTitle: String {
        switch self {
        case .edit: return "Edit"
        case .delete: return "Delete"
        case .markAsBought: return "Mark as Bought"
        }
    }
}
