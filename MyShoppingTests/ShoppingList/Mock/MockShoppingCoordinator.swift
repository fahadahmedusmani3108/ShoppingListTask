//
//  MockShoppingCoordinator.swift
//  MyShoppingTests
//
//  Created by Fahad Ahmed Usmani on 19/05/2025.
//

@testable import MyShopping

class MockShoppingCoordinator: ShoppingCoordinatorProtocol {
    var didNavigateToAddItem = false
       var didNavigateToUpdateItem = false
       var didPopViewController = false
       var lastUpdatedItem: ShoppingItemModel?
       
       // Protocol implementation
       func navigateToAddItem() {
           didNavigateToAddItem = true
       }
       
       func navigateToUpdateItem(with item: ShoppingItemModel) {
           didNavigateToUpdateItem = true
           lastUpdatedItem = item
       }
       
       func popViewController() {
           didPopViewController = true
       }
}
