//
//  MockShoppingViewModelFactory.swift
//  MyShoppingTests
//
//  Created by Fahad Ahmed Usmani on 19/05/2025.
//

@testable import MyShopping

class MockShoppingViewModelFactory: ShoppingViewModelFactoryProtocol {
    let container: MSDIContainer
    
    init(container: MSDIContainer) {
        self.container = container
    }

    func makeShoppingListViewModel() -> ShoppingListViewModel {
        container.resolve(ShoppingListViewModel.self)
    }

    func makeAddItemViewModel() -> AddItemViewModel {
        AddItemViewModel(
            repository: container.resolve(ShoppingRepository.self),
            coordinator: container.resolve(ShoppingCoordinatorProtocol.self)
        )
    }

    func makeEditItemViewModel(item: ShoppingItemModel) -> AddItemViewModel {
        AddItemViewModel(
            repository: container.resolve(ShoppingRepository.self),
            coordinator: container.resolve(ShoppingCoordinatorProtocol.self),
            item: item
        )
    }
}
