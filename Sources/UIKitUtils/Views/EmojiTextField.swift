//
//  EmojiTextField.swift
//  Vision_3 (iOS)
//
//  Created by Kai on 2022/4/24.
//

import UIKit

class EmojiTextField: UITextField {
    
    // required for iOS 13
    override var textInputContextIdentifier: String? { "" } // return non-nil to show the Emoji keyboard ¯\_(ツ)_/¯
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
}
