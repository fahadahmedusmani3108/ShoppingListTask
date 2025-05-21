//
//  ShoppingListCell.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 07/05/2025.
//

import UIKit
import Combine

class ShoppingListCell: UITableViewCell {

    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var quantityLabel: UILabel!
    @IBOutlet private(set) weak var notesLabel: UILabel!
    @IBOutlet private(set) weak var statusLabel: UILabel!
    private var index: Int?
    
    let didTapCellAccessory = PassthroughSubject<Int, Never>()

    func updateUI(with item: ShoppingItemModel, index: Int) {
        self.index = index
        titleLabel.text = item.title
        quantityLabel.text = "Quantity: \(item.quantity)"
        notesLabel.text = item.notes
        statusLabel.text = item.isBought ? "Bought" : "Not Bought"
    }

    @IBAction func didTapCellAccessory(_ sender: Any) {
        didTapCellAccessory.send(index ?? 0)
    }
}
