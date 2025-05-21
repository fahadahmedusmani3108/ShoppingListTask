//
//  ShoppingListViewModelTests.swift
//  MyShoppingTests
//
//  Created by Fahad Ahmed Usmani on 17/05/2025.
//

import XCTest
import Combine
@testable import MyShopping

class ShoppingListViewModelTests: XCTestCase {
    var viewModel: ShoppingListViewModel!
    var mockRepository: MockShoppingItemRepository!
    var mockCoordinator: MockShoppingCoordinator!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Test Lifecycle
    override func setUp() {
        super.setUp()
        cancellables = []
        mockRepository = MockShoppingItemRepository()
        mockCoordinator = MockShoppingCoordinator()
        viewModel = ShoppingListViewModel(
            repository: mockRepository,
            coordinator: mockCoordinator
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        mockCoordinator = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func test_init_setsUpCorrectly() {
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.filteredItems.count, 0)
        XCTAssertFalse(mockRepository.mockItems.isEmpty == false)
    }
    
    // MARK: - Data Loading Tests
    
    func test_loadUI_successfullyLoadsItems() async {
        // Given
        mockRepository.mockItems = [
            ShoppingItemModel(id: 1, title: "Milk", quantity: 2, notes: "Test",
                              isBought: false, createdAt: "", modifiedAt: "")
        ]
        let expectation = XCTestExpectation(description: "Items loaded")
        
        viewModel.reloadUIHandler.sink { _ in
            expectation.fulfill()
        }.store(in: &cancellables)
        
        // When
        viewModel.loadUI()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.filteredItems.count, 1)
    }
    
    func test_loadUI_handlesError() async {
        // Given
        mockRepository.shouldThrowError = true
        let expectation = XCTestExpectation(description: "Error handled")
        
        viewModel.showErrorUIHandler.sink { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }.store(in: &cancellables)
        
        // When
        viewModel.loadUI()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - Sorting Tests
    func test_didTapSort_togglesSortOrderCorrectly() async {
        // Given
        mockRepository.mockItems = [
            ShoppingItemModel(id: 1, title: "Milk", quantity: 2, notes: "",
                              isBought: false, createdAt: "2023-01-02", modifiedAt: "2025-01-02"),
            ShoppingItemModel(id: 2, title: "Bread", quantity: 1, notes: "",
                              isBought: true, createdAt: "2023-01-01", modifiedAt: "2025-01-01")
        ]
        
        // Wait for initial load to complete
        let initialLoadExpectation = XCTestExpectation(description: "Initial load")
        viewModel.reloadUIHandler.sink { _ in
            initialLoadExpectation.fulfill()
        }.store(in: &cancellables)
        
        await fulfillment(of: [initialLoadExpectation], timeout: 1.0)
        
        // Verify pre-condition
        XCTAssertEqual(viewModel.filteredItems.count, 2)
        
        // Set up descending expectation
        let descendingExpectation = XCTestExpectation(description: "Descending sort")
        viewModel.reloadUIHandler.sink { _ in
            descendingExpectation.fulfill()
        }.store(in: &cancellables)
        
        // When
        viewModel.didTapSort()
        
        // Then
        await fulfillment(of: [descendingExpectation], timeout: 1.0)
        XCTAssertEqual(viewModel.filteredItems[0].id, 1)
        XCTAssertEqual(viewModel.filteredItems[1].id, 2)
        
        // Set up ascending expectation
        let ascendingExpectation = XCTestExpectation(description: "Ascending sort")
        viewModel.reloadUIHandler.sink { _ in
            ascendingExpectation.fulfill()
        }.store(in: &cancellables)
        
        // When
        viewModel.didTapSort()
        
        // Then
        await fulfillment(of: [ascendingExpectation], timeout: 1.0)
        XCTAssertEqual(viewModel.filteredItems[0].id, 2)
        XCTAssertEqual(viewModel.filteredItems[1].id, 1)
    }
    
    func test_search_hidesSegmentControlWhenActive() {
        // Given
        let expectation = XCTestExpectation(description: "Segment visibility updated")
        
        viewModel.shouldHideSegmentUIHandler.sink { shouldHide in
            XCTAssertTrue(shouldHide)
            expectation.fulfill()
        }.store(in: &cancellables)
        
        // When
        viewModel.didUpdateSearchText(searchText: "test")
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Quick Actions Tests
    func test_didTapQuickAction_edit_navigatesToUpdate() async {
        // Given
        let testItem = ShoppingItemModel(id: 1, title: "Test", quantity: 1,
                                         notes: "", isBought: false,
                                         createdAt: "", modifiedAt: "")
        mockRepository.mockItems = [testItem]
        
        let loadExpectation = XCTestExpectation(description: "Initial data load")
        viewModel.reloadUIHandler.sink { _ in
            loadExpectation.fulfill()
        }.store(in: &cancellables)
        
        await fulfillment(of: [loadExpectation], timeout: 1.0)
        
        XCTAssertEqual(viewModel.filteredItems.count, 1, "Should have one item loaded")
        
        // When
        viewModel.didTapQuickAction(for: .edit, index: 0)
        
        // Then
        XCTAssertTrue(mockCoordinator.didNavigateToUpdateItem, "Should navigate to edit screen")
        XCTAssertEqual(mockCoordinator.lastUpdatedItem?.id, testItem.id, "Should pass correct item to edit")
    }
    
    func test_didTapQuickAction_delete_removesItem() async {
        // Given
        let testItem = ShoppingItemModel(id: 1, title: "Test", quantity: 1,
                                         notes: "", isBought: false,
                                         createdAt: "", modifiedAt: "")
        mockRepository.mockItems = [testItem]
        
        // 2. Wait for initial load to complete
        let initialLoadExpectation = XCTestExpectation(description: "Initial load")
        viewModel.reloadUIHandler.sink { _ in
            initialLoadExpectation.fulfill()
        }.store(in: &cancellables)
        
        await fulfillment(of: [initialLoadExpectation], timeout: 1.0)
        
        // 3. Verify pre-condition
        XCTAssertEqual(viewModel.filteredItems.count, 1)
        
        // 4. Set up deletion expectation
        let deletionExpectation = XCTestExpectation(description: "Item deleted")
        viewModel.reloadUIHandler.sink { _ in
            deletionExpectation.fulfill()
        }.store(in: &cancellables)
        
        // When
        viewModel.didTapQuickAction(for: .delete, index: 0)
        
        // Then
        await fulfillment(of: [deletionExpectation], timeout: 1.0)
        XCTAssertTrue(mockRepository.didCallDelete)
        XCTAssertEqual(viewModel.filteredItems.count, 0)
    }
    
    func test_didTapQuickAction_markAsBought_togglesStatus() async {
        // Given
        let testItem = ShoppingItemModel(id: 1, title: "Test", quantity: 1,
                                         notes: "", isBought: false,
                                         createdAt: "", modifiedAt: "")
        mockRepository.mockItems = [testItem]
        
        // 2. Wait for initial load
        let initialExpectation = XCTestExpectation(description: "Initial load")
        viewModel.reloadUIHandler.sink { _ in
            initialExpectation.fulfill()
        }.store(in: &cancellables)
        
        await fulfillment(of: [initialExpectation], timeout: 1.0)
        
        // First toggle (mark as bought)
        let firstToggleExpectation = XCTestExpectation(description: "First toggle")
        viewModel.reloadUIHandler.sink { _ in
            firstToggleExpectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.didTapQuickAction(for: .markAsBought, index: 0)
        await fulfillment(of: [firstToggleExpectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(viewModel.filteredItems.count, 1)
        XCTAssertTrue(viewModel.filteredItems[0].isBought)
        
        // Second toggle (mark as unbought)
        let secondToggleExpectation = XCTestExpectation(description: "Second toggle")
        viewModel.reloadUIHandler.sink { _ in
            secondToggleExpectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.didTapQuickAction(for: .markAsBought, index: 0)
        await fulfillment(of: [secondToggleExpectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(viewModel.filteredItems.count, 1)
        XCTAssertFalse(viewModel.filteredItems[0].isBought)
    }
    
    // MARK: - Navigation Tests
    func test_didTapAdd_navigatesToAddItem() {
        // When
        viewModel.didTapAdd()
        
        // Then
        XCTAssertTrue(mockCoordinator.didNavigateToAddItem)
    }

    // MARK: - Publisher Tests
    func test_itemsPublisher_updatesFilteredItems() {
        let testItems = [
            ShoppingItemModel(id: 1, title: "Test", quantity: 1,
                              notes: "", isBought: false,
                              createdAt: "", modifiedAt: "")
        ]
        let expectation = XCTestExpectation(description: "Items updated")
        
        viewModel.reloadUIHandler.sink { _ in
            expectation.fulfill()
        }.store(in: &cancellables)
        
        // When
        mockRepository.mockItems = testItems
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.filteredItems.count, 1)
    }
}
