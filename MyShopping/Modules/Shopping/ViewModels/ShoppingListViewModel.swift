//
//  ShoppingListViewModel.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 07/05/2025.
//

import Combine

class ShoppingListViewModel {
    // MARK: - Displayable properties
    var filteredItems: [ShoppingItemModel] = []

    // MARK: - Actionable properties
    var reloadUIHandler: PassthroughSubject<Void, Never> = .init()
    var showLoaderUIHandler: PassthroughSubject<Bool, Never> = .init()
    var showErrorUIHandler: PassthroughSubject<Error?, Never> = .init()
    var shouldHideSegmentUIHandler: PassthroughSubject<Bool, Never> = .init()

    // MARK: - Private properties
    private let repository: ShoppingRepository
    private let coordinator: ShoppingCoordinatorProtocol
    private var cancellables = Set<AnyCancellable>()
    private var items: [ShoppingItemModel] = [] {
        didSet {
            applyFilter(with: .status)
        }
    }
    private var segments: [ShoppingListItemStatus] = [.all, .bought, .unBought]
    private var selectedSegmentIndex: Int = 0
    private var selectedSortOrder: ShoppingListSortOrder = .ascending

    init(repository: ShoppingRepository, coordinator: ShoppingCoordinatorProtocol) {
        self.repository = repository
        self.coordinator = coordinator
        observeItems()
    }
}

// MARK: - ShoppingListViewModelDisplayables
extension ShoppingListViewModel: ShoppingListViewModelDisplayable {}

// MARK: - ShoppingListViewModelActionables
extension ShoppingListViewModel: ShoppingListViewModelActionable {
    func loadUI() {
        Task {
            await fetchShoppingList()
            reloadUIHandler.send(())
        }
    }

    func didTapQuickAction(for action: ShoppingListQuickAction, index: Int) {
        switch action {
        case .edit:
            didTapEdit(with: filteredItems[index])
        case .delete:
            didTapDelete(with: filteredItems[index])
        case .markAsBought:
            markItemAsBought(at: index)
        }
    }

    func didChangeSegment(selectedIndex: Int) {
        selectedSegmentIndex = selectedIndex
        applyFilter(with: .status)
    }

    func didUpdateSearchText(searchText: String) {
        searchItems(with: searchText)
    }

    func didTapAdd() {
        coordinator.navigateToAddItem()
    }

    func didTapSort() {
        applyFilter(with: .sort)
    }
}

private extension ShoppingListViewModel {
    func fetchShoppingList() async {
        Task {
            do {
                try await repository.getShoppingItems()
            } catch(let error) {
                showErrorUIHandler.send(error)
            }
        }
    }

    func markItemAsBought(at index: Int) {
        guard index < items.count else { return }
        var item = filteredItems[index]
        item.isBought.toggle()
        filteredItems[index] = item
        if let itemIndex = items.firstIndex(where: { $0.id == item.id }) {
            items[itemIndex] = item
        }
        filterItemsByStatus()
        reloadUIHandler.send(())
    }

    func didTapEdit(with item: ShoppingItemModel) {
        coordinator.navigateToUpdateItem(with: item)
    }

    func didTapDelete(with item: ShoppingItemModel) {
        Task {
            do {
                try await repository.deleteShoppingItem(with: item.id)
            } catch(let error) {
                showErrorUIHandler.send(error)
            }
        }
    }
}

private extension ShoppingListViewModel {
    func observeItems() {
        repository.itemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.items = items
            }
            .store(in: &cancellables)
    }

    func applyFilter(with filterType: ShoppingListFilters) {
        switch filterType {
        case .status:
            filterItemsByStatus()
        case .sort:
            selectedSortOrder = selectedSortOrder == .ascending ? .descending : .ascending
        case .search(let searchText):
            searchItems(with: searchText)
        }
        sortItems()
        reloadUIHandler.send()
    }

    func filterItemsByStatus() {
        switch segments[selectedSegmentIndex] {
        case .all:
            filteredItems = items
        case .bought:
            filteredItems = items.filter { $0.isBought }
        case .unBought:
            filteredItems = items.filter { !$0.isBought }
        }
    }

    func sortItems() {
        if selectedSortOrder == .ascending {
            filteredItems.sort { $0.modifiedAt < $1.modifiedAt }
        } else {
            filteredItems.sort { $0.modifiedAt > $1.modifiedAt }
        }
    }

    func searchItems(with searchText: String) {
        guard !searchText.isEmpty else {
            shouldHideSegmentUIHandler.send(false)
            filteredItems = items
            return
        }
        shouldHideSegmentUIHandler.send(true)
        filteredItems = items.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) || $0.notes.localizedCaseInsensitiveContains(searchText)
        }
    }
}
