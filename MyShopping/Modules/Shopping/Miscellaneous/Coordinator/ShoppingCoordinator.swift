//
//  ShoppingCoordinator.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 15/05/2025.
//

import UIKit

protocol ShoppingCoordinatorProtocol: AnyObject {
    func navigateToAddItem()
    func popViewController()
    func navigateToUpdateItem(with item: ShoppingItemModel)
}

class ShoppingCoordinator: ShoppingCoordinatorProtocol {
    private let navigationController: UINavigationController
    private let container: MSDIContainer
    private let viewModelFactory: ShoppingViewModelFactoryProtocol
    private let storyboard = UIStoryboard(name: "Shopping", bundle: Bundle(for: ShoppingCoordinator.self))

    init(navigationController: UINavigationController, 
         container: MSDIContainer,
         viewModelFactory: ShoppingViewModelFactoryProtocol) {
        self.navigationController = navigationController
        self.container = container
        self.viewModelFactory = viewModelFactory
    }

    func start() {
        guard let viewController = storyboard.instantiateViewController(withIdentifier: ShoppingListViewController.identifier) as? ShoppingListViewController else {
            return
        }
        viewController.viewModel = viewModelFactory.makeShoppingListViewModel()
        navigationController.pushViewController(viewController, animated: true)
    }

    func navigateToAddItem() {
        guard let viewController = storyboard.instantiateViewController(withIdentifier: AddItemViewController.identifier) as? AddItemViewController else {
            return
        }
        viewController.viewModel = viewModelFactory.makeAddItemViewModel()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func navigateToUpdateItem(with item: ShoppingItemModel) {
        guard let viewController = storyboard.instantiateViewController(withIdentifier: AddItemViewController.identifier) as? AddItemViewController else {
            return
        }
        viewController.viewModel = viewModelFactory.makeEditItemViewModel(item: item)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func popViewController() {
        navigationController.popViewController(animated: true)
    }
}

