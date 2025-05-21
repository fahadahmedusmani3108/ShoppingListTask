//
//  AddItemViewModel.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 15/05/2025.
//

import Combine

class AddItemViewModel {
    private let repository: ShoppingRepository
    private let coordinator: ShoppingCoordinatorProtocol
    private let item: ShoppingItemModel?
    var itemPublisher: PassthroughSubject<ShoppingItemModel, Never> = .init()

    init(repository: ShoppingRepository, coordinator: ShoppingCoordinatorProtocol, item: ShoppingItemModel? = nil) {
        self.repository = repository
        self.coordinator = coordinator
        self.item = item
    }
}

extension AddItemViewModel: AddItemViewModelDisplayable {}

extension AddItemViewModel: AddItemViewModelActionable {
   func loadUI() {
       if let shoppingItem = item {
           itemPublisher.send(shoppingItem)
       }
    }

    func didTapConfirm(title: String?, quantity: String?, notes: String?) {
        addItem(title: title, quantity: quantity, notes: notes)
    }
}
    
private extension AddItemViewModel {
    func addItem(title: String?, quantity: String?, notes: String?) {
        Task {
            do {
                let newItem = ShoppingItemModel(id: item?.id ?? 0,
                                                title: title ?? "",
                                                quantity: Int(quantity ?? "") ?? 0,
                                                notes: notes ?? "",
                                                isBought: item?.isBought ?? false,
                                                createdAt: item?.createdAt ?? CoreHelper.shared.getCurrentDate(),
                                                modifiedAt: CoreHelper.shared.getCurrentDate())
                try await repository.addShoppingItem(item: newItem)
                DispatchQueue.main.async { [weak self] in
                    self?.coordinator.popViewController()
                }
            } catch(let error) {
                print("Error adding item: \(error)")
            }
        }
    }
}
