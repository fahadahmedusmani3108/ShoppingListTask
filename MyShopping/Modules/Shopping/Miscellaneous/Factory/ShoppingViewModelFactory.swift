//
//  ShoppingViewModelFactory.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 16/05/2025.
//

import Foundation

protocol ShoppingViewModelFactoryProtocol {
    func makeShoppingListViewModel() -> ShoppingListViewModel
    func makeAddItemViewModel() -> AddItemViewModel
    func makeEditItemViewModel(item: ShoppingItemModel) -> AddItemViewModel
}

final class ShoppingViewModelFactory: ShoppingViewModelFactoryProtocol {
    private let container: MSDIContainer

    init(container: MSDIContainer) {
        self.container = container
    }

    func makeShoppingListViewModel() -> ShoppingListViewModel {
        ShoppingListViewModel(
            repository: container.resolve(ShoppingItemRepository.self),
            coordinator: container.resolve(ShoppingCoordinator.self)
        )
    }

    func makeAddItemViewModel() -> AddItemViewModel {
        AddItemViewModel(
            repository: container.resolve(ShoppingItemRepository.self),
            coordinator: container.resolve(ShoppingCoordinator.self)
        )
    }

    func makeEditItemViewModel(item: ShoppingItemModel) -> AddItemViewModel {
        AddItemViewModel(
            repository: container.resolve(ShoppingItemRepository.self),
            coordinator: container.resolve(ShoppingCoordinator.self),
            item: item
        )
    }
}
