//
//  AddItemViewModelAdaptable.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 15/05/2025.
//

import Combine

typealias AddItemViewModelAdaptable = AddItemViewModelDisplayable & AddItemViewModelActionable

protocol AddItemViewModelDisplayable {
    
}

protocol AddItemViewModelActionable {
    var itemPublisher: PassthroughSubject<ShoppingItemModel, Never> { get }
    func didTapConfirm(title: String?, quantity: String?, notes: String?)
    func loadUI()
}
