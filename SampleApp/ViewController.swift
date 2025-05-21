//
//  ViewController.swift
//  SampleApp
//
//  Created by Fahad Ahmed Usmani on 08/05/2025.
//

import UIKit
import MyShopping

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyShoppingSDK.initialize(with: navigationController)
    }
}

