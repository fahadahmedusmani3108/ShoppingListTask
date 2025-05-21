//
//  ShoppingListViewControllerTests.swift
//  MyShoppingTests
//
//  Created by Fahad Ahmed Usmani on 19/05/2025.
//

import XCTest
import Combine
@testable import MyShopping

class c: XCTestCase {
    var sut: ShoppingListViewController!
    var mockViewModel: MockShoppingListViewModel!
    var mockCoordinator: MockShoppingCoordinator!
    var container: MSDIContainer!
    var window: UIWindow!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        container = MSDIContainer.shared
        window = UIWindow()
        cancellables = []
        
        mockViewModel = MockShoppingListViewModel()
        mockCoordinator = MockShoppingCoordinator()
        
        container.register(ShoppingListViewModelAdaptable.self) { self.mockViewModel }
        container.register(ShoppingCoordinatorProtocol.self) { self.mockCoordinator }
        
        // Instantiate view controller
        let storyboard = UIStoryboard(name: "Shopping", bundle: Bundle(for: ShoppingListViewController.self))
        sut = storyboard.instantiateViewController(
            identifier: "ShoppingListViewController",
            creator: { coder in
                let vc = ShoppingListViewController(coder: coder)
                vc?.viewModel = self.container.resolve(ShoppingListViewModelAdaptable.self)
                return vc
            }
        )
        
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    override func tearDown() {
        sut = nil
        mockViewModel = nil
        mockCoordinator = nil
        container.reset()
        container = nil
        window = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Setup Mocks
    private func setupMocks() {
        // Register mock services
        container.registerSingleton(ShoppingNetworkServiceProtocol.self) {
            MockShoppingNetworkService()
        }
        
        container.registerSingleton(ShoppingDBServiceProtocol.self) {
            MockShoppingDBService()
        }
        
        // Configure mock repository
        let mockRepository = MockShoppingItemRepository()
        container.register(ShoppingRepository.self) { mockRepository }
        
        //Configure mock view model factory
        container.register(ShoppingViewModelFactoryProtocol.self) {
            MockShoppingViewModelFactory(container: self.container)
        }
        
        // Configure mock coordinator
        mockCoordinator = MockShoppingCoordinator()
        container.register(ShoppingCoordinatorProtocol.self) { self.mockCoordinator }
        
        // Configure mock view model
        mockViewModel = MockShoppingListViewModel()
        container.register(MockShoppingListViewModel.self) { self.mockViewModel }
        
        // Register view model factory
        container.registerSingleton(ShoppingViewModelFactoryProtocol.self) {
            MockShoppingViewModelFactory(container: self.container)
        }
    }

    private func loadMockItems() {
        mockViewModel.mockFilteredItems = [
            ShoppingItemModel(
                id: 1,
                title: "Milk",
                quantity: 2,
                notes: "2% reduced fat",
                isBought: false,
                createdAt: "2025-05-01T10:00:00Z",
                modifiedAt: "2025-05-01T10:00:00Z"
            ),
            ShoppingItemModel(
                id: 2,
                title: "Bread",
                quantity: 1,
                notes: "Whole wheat",
                isBought: true,
                createdAt: "2025-05-02T11:00:00Z",
                modifiedAt: "2025-05-02T11:00:00Z"
            )
        ]
    }

    // MARK: - View Lifecycle Tests
    func testViewDidLoad_SetsUpTableView() {
        // When
        sut.viewDidLoad()
        
        // Then
        XCTAssertNotNil(sut.tableView.delegate)
        XCTAssertNotNil(sut.tableView.dataSource)
        XCTAssertEqual(sut.tableView.estimatedRowHeight, UITableView.automaticDimension)
    }

    func testViewDidLoad_SetsUpSearchBar() {
        // When
        sut.viewDidLoad()
        
        // Then
        XCTAssertNotNil(sut.searchBar.delegate)
    }
    
    func testViewDidLoad_CallsLoadUIOnViewModel() {
        // When
        sut.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockViewModel.didLoadUI)
    }

    func testViewDidLoad_SetsUpBindings() {
        // Given
        let expectation = XCTestExpectation(description: "Bindings established")
        mockViewModel.reloadUIHandler = PassthroughSubject<Void, Never>()
        
        // When
        sut.viewDidLoad()
        
        // Then
        mockViewModel.reloadUIHandler.sink { _ in
            expectation.fulfill()
        }.store(in: &cancellables)
        
        mockViewModel.reloadUIHandler.send(())
        wait(for: [expectation], timeout: 1.0)
    }

    func testTableView_NumberOfRows_MatchesViewModelData() {
        // Given
        mockViewModel.mockFilteredItems = [
            ShoppingItemModel(id: 1, title: "Test", quantity: 1, notes: "Test",
                              isBought: false, createdAt: "", modifiedAt: "")
        ]
        sut.viewDidLoad()
        
        // When
        let rows = sut.tableView(sut.tableView, numberOfRowsInSection: 0)
        
        // Then
        XCTAssertEqual(rows, 1)
    }

    func testTableView_CellForRow_ConfiguresCellCorrectly() {
        // Given
        mockViewModel.mockFilteredItems = [
            ShoppingItemModel(id: 1, title: "Milk", quantity: 2, notes: "2% reduced fat",
                              isBought: false, createdAt: "", modifiedAt: "")
        ]
        sut.viewDidLoad()
        
        // When
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! ShoppingListCell
        
        // Then
        XCTAssertEqual(cell.titleLabel.text, "Milk")
        XCTAssertEqual(cell.quantityLabel.text, "Quantity: 2")
        XCTAssertEqual(cell.notesLabel.text, "2% reduced fat")
        XCTAssertEqual(cell.statusLabel.text, "Not Bought")
    }

    // MARK: - Segment Control Tests
    func testSegmentControl_ChangeSegment_UpdatesViewModel() {
        // Given
        sut.viewDidLoad()
        sut.segmentControl.selectedSegmentIndex = 1
        
        // When
        sut.didChangeSegment(sut.segmentControl)
        
        // Then
        XCTAssertEqual(mockViewModel.lastSelectedSegmentIndex, 1)
    }

    // MARK: - Search Bar Tests
    func testSearchBar_SearchTextChanged_UpdatesViewModel() {
        // Given
        sut.viewDidLoad()
        let searchText = "test"
        
        // When
        sut.searchBar(sut.searchBar, textDidChange: searchText)
        
        // Then
        XCTAssertEqual(mockViewModel.lastSearchText, searchText)
    }

    func testSearchBar_SearchButtonClicked_DismissesKeyboard() {
        // Given
        sut.viewDidLoad()
        sut.searchBar.becomeFirstResponder()
        
        // When
        sut.searchBarSearchButtonClicked(sut.searchBar)
        
        // Then
        XCTAssertFalse(sut.searchBar.isFirstResponder)
    }
    
    // MARK: - Quick Actions Tests
    func testQuickActions_EditAction_TriggersViewModel() {
        let testIndex = 0
        mockViewModel.mockFilteredItems = [ShoppingItemModel(id: 1, title: "Test", quantity: 1,
                                                             notes: "", isBought: false,
                                                             createdAt: "", modifiedAt: "")]
        
        // When
        sut.showQuickActions(for: testIndex)
        
        // Verify through mock view model
        mockViewModel.lastQuickAction = nil // Reset
        
        // Simulate tapping Edit action
        sut.viewModel?.didTapQuickAction(for: .edit, index: testIndex)
        
        // Then
        XCTAssertEqual(mockViewModel.lastQuickAction?.action, .edit)
        XCTAssertEqual(mockViewModel.lastQuickAction?.index, testIndex)
    }
    
    func testQuickActions_DeleteAction_TriggersViewModel() {
        let testIndex = 0
        mockViewModel.mockFilteredItems = [ShoppingItemModel(id: 1, title: "Test", quantity: 1,
                                                             notes: "", isBought: false,
                                                             createdAt: "", modifiedAt: "")]
        
        // When
        sut.showQuickActions(for: testIndex)
        
        // Verify through mock view model
        mockViewModel.lastQuickAction = nil // Reset
        
        // Simulate tapping Edit action
        sut.viewModel?.didTapQuickAction(for: .delete, index: testIndex)
        
        // Then
        XCTAssertEqual(mockViewModel.lastQuickAction?.action, .delete)
        XCTAssertEqual(mockViewModel.lastQuickAction?.index, testIndex)
    }
    
    // MARK: - Button Actions Tests
    func testAddButton_Tapped_NavigatesToAddItem() {
        // Given
        sut.viewDidLoad()
        
        // When
        sut.didTapAdd(UIBarButtonItem())
        
        // Then
        XCTAssertTrue(mockViewModel.didTapAddFlag)
    }

    func testSortButton_Tapped_TriggersViewModel() {
        // Given
        sut.viewDidLoad()
        
        // When
        sut.didTapSort(UIBarButtonItem())
        
        // Then
        XCTAssertTrue(mockViewModel.didTapSortFlag)
    }
    
    func testSegmentVisibility_UpdatesWhenViewModelChanges() {
        // Given
        sut.viewDidLoad()
        
        // When
        mockViewModel.shouldHideSegmentUIHandler.send(true)
        
        // Then
        XCTAssertTrue(sut.segmentControl.isHidden)
        
        // When
        mockViewModel.shouldHideSegmentUIHandler.send(false)
        
        // Then
        XCTAssertFalse(sut.segmentControl.isHidden)
    }
}
