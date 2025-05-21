//
//  AddItemViewController.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 15/05/2025.
//

import UIKit
import Combine

class AddItemViewController: UIViewController {
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var notesField: UITextField!
    
    var viewModel: AddItemViewModelAdaptable?
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
        viewModel?.loadUI()
    }

    @IBAction func didTapConfirm(_ sender: Any) {
        viewModel?.didTapConfirm(title: titleField.text,
                                 quantity: quantityField.text,
                                 notes: notesField.text)
    }
}

extension AddItemViewController {
    private func setupUI() {
        title = "Add Item"
        titleField.placeholder = "Enter item title"
        quantityField.placeholder = "Enter item quantity"
        notesField.placeholder = "Enter item notes"
    }
    private func setupBinding() {
        viewModel?.itemPublisher.sink { [weak self] item in
            guard let wSelf = self else { return }
            wSelf.titleField.text = item.title
            wSelf.quantityField.text = "\(item.quantity)"
            wSelf.notesField.text = item.notes
        }.store(in: &cancellables)
    }
}
