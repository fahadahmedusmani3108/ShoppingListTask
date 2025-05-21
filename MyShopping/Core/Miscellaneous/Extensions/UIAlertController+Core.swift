//
//  UIAlertController+Core.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 09/05/2025.
//

import UIKit

extension UIAlertController {
    class func actionSheet(title: String? = nil, message: String? = nil, actions: [UIAlertAction], cancelButtonTapped: (() -> Void)? = nil) -> UIAlertController {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for action in actions { actionSheet.addAction(action) }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            cancelButtonTapped?()
        }
        actionSheet.addAction(cancelAction)
        return actionSheet
    }
}
