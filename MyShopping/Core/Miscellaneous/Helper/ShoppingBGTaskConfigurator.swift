//
//  ShoppingBGTaskConfigurator.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 16/05/2025.
//

import BackgroundTasks

public enum ShoppingBGTaskConfigurator {

    public static func performSync() async {
        MSDIConfigurator.configure()
        let repository: ShoppingRepository = MSDIContainer.shared.resolve(ShoppingItemRepository.self)
        await repository.performBackgroundSync()
    }
}
