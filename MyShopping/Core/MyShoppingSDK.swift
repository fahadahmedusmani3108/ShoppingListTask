//
//  MyShoppingSDK.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 08/05/2025.
//

import Foundation
import UIKit

public struct MyShoppingSDK {
    var coordinator: ShoppingCoordinator?
    
    public static func initialize(with navigationController: UINavigationController?) {
        MSDIConfigurator.configure(with: navigationController ?? UINavigationController())
        let coordinator: ShoppingCoordinator = MSDIContainer.shared.resolve(ShoppingCoordinator.self)
        coordinator.start()
    }
}
