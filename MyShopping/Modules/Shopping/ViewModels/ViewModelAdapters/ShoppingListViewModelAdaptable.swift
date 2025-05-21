//
//  ShoppingListViewModelAdaptable.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 07/05/2025.
//
import Combine

typealias ShoppingListViewModelAdaptable = ShoppingListViewModelDisplayable & ShoppingListViewModelActionable

protocol ShoppingListViewModelDisplayable {
    var filteredItems: [ShoppingItemModel] { get }
}

protocol ShoppingListViewModelActionable {
    var reloadUIHandler: PassthroughSubject<Void, Never> { get set }
    var shouldHideSegmentUIHandler: PassthroughSubject<Bool, Never> { get set }
    var showLoaderUIHandler: PassthroughSubject<Bool, Never> { get set }
    var showErrorUIHandler: PassthroughSubject<Error?, Never> { get set }

    func loadUI()
    func didTapQuickAction(for: ShoppingListQuickAction, index: Int)
    func didTapAdd()
    func didTapSort()
    func didUpdateSearchText(searchText: String)
    func didChangeSegment(selectedIndex: Int)
}
