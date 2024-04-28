//
//  CustomUITextField.swift
//  Aura
//
//  Created by Quinn O'Donnell on 4/27/24.
//

import Foundation
import SwiftUI
import UIKit
import WebKit

class CustomUITextField: UITextField {
    
    var onUpArrow: (() -> Void)?
    var onDownArrow: (() -> Void)?
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            guard let key = press.key else { continue }
            
            switch key.keyCode {
            case .keyboardUpArrow:
                onUpArrow?() // Trigger the action for up arrow key
                return
            case .keyboardDownArrow:
                onDownArrow?() // Trigger the action for down arrow key
                return
            default:
                break
            }
        }
        
        super.pressesBegan(presses, with: event)
    }
}
