//
//  CoreHelper.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 16/05/2025.
//

import Foundation

class CoreHelper {
    static let shared = CoreHelper()
    
    private init() {}
    
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
}
