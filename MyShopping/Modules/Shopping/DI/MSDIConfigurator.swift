//
//  MSDIConfigurator.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 13/05/2025.
//

import Foundation
import UIKit

final class MSDIConfigurator {
    static func configure(with navigationController: UINavigationController? = nil) {
        let container = MSDIContainer.shared
        container.registerSingleton(ShoppingNetworkService.self) {
            ShoppingNetworkService()
        }
        container.registerSingleton(ShoppingDBService.self) {
            ShoppingDBService()
        }
        container.registerSingleton(ShoppingViewModelFactory.self) {
            ShoppingViewModelFactory(container: container)
        }
        container.register(ShoppingItemRepository.self) {
            ShoppingItemRepository(
                dbRepository: container.resolve(ShoppingDBService.self),
                networkRepository: container.resolve(ShoppingNetworkService.self)
            )
        }
        container.register(ShoppingCoordinator.self) {
            ShoppingCoordinator(navigationController: navigationController ?? UINavigationController(),
                                container: container,
                                viewModelFactory: container.resolve(ShoppingViewModelFactory.self))
        }
    }
}
