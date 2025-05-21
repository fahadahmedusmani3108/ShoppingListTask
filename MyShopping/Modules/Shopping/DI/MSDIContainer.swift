//
//  MSDIContainer.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 08/05/2025.
//

import Foundation

final class MSDIContainer {
    
    // MARK: - Singleton
    static let shared = MSDIContainer()
    
    // MARK: - Internal Stores
    private var factories: [ObjectIdentifier: () -> Any] = [:]
    private var singletons: [ObjectIdentifier: Any] = [:]
    
    private init() {}
    
    // MARK: - Register Factory
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        factories[ObjectIdentifier(type)] = factory
    }
    
    // MARK: - Register Singleton (Lazy)
    func registerSingleton<T>(_ type: T.Type, factory: @escaping () -> T) {
        factories[ObjectIdentifier(type)] = { [weak self] in
            if let instance = self?.singletons[ObjectIdentifier(type)] as? T {
                return instance
            }
            let newInstance = factory()
            self?.singletons[ObjectIdentifier(type)] = newInstance
            return newInstance
        }
    }

    // MARK: - Resolve Dependency
    func resolve<T>(_ type: T.Type) -> T {
        guard let factory = factories[ObjectIdentifier(type)],
              let instance = factory() as? T else {
            fatalError("No factory registered for type \(T.self)")
        }
        return instance
    }

    // MARK: - Override (for Testing)
    func override<T>(_ type: T.Type, with factory: @escaping () -> T) {
        factories[ObjectIdentifier(type)] = factory
        singletons[ObjectIdentifier(type)] = nil
    }
    
    // MARK: - Reset (optional)
    func reset() {
        factories.removeAll()
        singletons.removeAll()
    }
}
