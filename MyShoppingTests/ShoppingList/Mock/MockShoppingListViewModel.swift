//
//  MockShoppingListViewModel.swift
//  MyShoppingTests
//
//  Created by Fahad Ahmed Usmani on 19/05/2025.
//

import Combine
@testable import MyShopping

class MockShoppingListViewModel: ShoppingListViewModelAdaptable {
    // Test data
    var mockFilteredItems: [ShoppingItemModel] = []
    
    // Protocol requirements
    var filteredItems: [ShoppingItemModel] { mockFilteredItems }
    var reloadUIHandler = PassthroughSubject<Void, Never>()
    var shouldHideSegmentUIHandler = PassthroughSubject<Bool, Never>()
    var showLoaderUIHandler = PassthroughSubject<Bool, Never>()
    var showErrorUIHandler = PassthroughSubject<Error?, Never>()
    
    // Test tracking
    var didLoadUI = false
    var didTapSortFlag = false
    var didTapAddFlag = false
    var lastSelectedSegmentIndex: Int?
    var lastSearchText: String?
    var lastQuickAction: (action: ShoppingListQuickAction, index: Int)?
    
    // Protocol implementation
    func loadUI() {
        didLoadUI = true
    }
    
    func didTapQuickAction(for action: ShoppingListQuickAction, index: Int) {
        lastQuickAction = (action, index)
    }
    
    func didChangeSegment(selectedIndex: Int) {
        lastSelectedSegmentIndex = selectedIndex
    }
    
    func didUpdateSearchText(searchText: String) {
        lastSearchText = searchText
    }
    
    func didTapAdd() {
        didTapAddFlag = true
    }
    
    func didTapSort() {
        didTapSortFlag = true
    }
}
