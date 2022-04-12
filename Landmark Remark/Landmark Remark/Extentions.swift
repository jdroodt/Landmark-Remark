//
//  Extentions.swift
//  Landmark Remark
//
//  Created by JD on 12/4/2022.
//

import Foundation
import UIKit

extension UIImage {
    
    // Image shortcut
    public convenience init?(systemName name: String, size: CGFloat) {
        let weight: UIImage.SymbolWeight = .regular  // Change here for app wide
        var config = UIImage.SymbolConfiguration(weight: weight)
        config = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
        self.init(systemName: name, withConfiguration: config)
    }
    
}


extension UIViewController {
    
    // Shortcut to show basic AlertController
    public func showMessage(_ text: String, message: String? = nil) {
        let alert = UIAlertController(title: text, message: message, preferredStyle: .alert)
        let doneButton = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(doneButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Shortcut to get text from AlertController
    public func showInput(header: String, message: String? = nil, placeholderText: String, completion: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: header, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = placeholderText
        }
        let confirmButton = UIAlertAction(title: "Save", style: .default) { [weak alert] _ in
            if let textField = alert?.textFields?.first, let text = textField.text {
                completion(text)
            } else {
                print("ERROR: No textfield detected on Alert!")
            }
        }
        alert.addAction(confirmButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}


