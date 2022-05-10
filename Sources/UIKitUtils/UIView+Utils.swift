//
//  UIView+Utils.swift
//  Vision 3 (iOS)
//
//  Created by Kai on 2022/3/7.
//

import UIKit
import SwiftUI

extension UIView {
    var parentViewController: UIViewController? {
        sequence(first: self) { $0.next }
            .first(where: { $0 is UIViewController })
            .flatMap { $0 as? UIViewController }
    }
}

extension UIColor {
    static var accentColor: UIColor {
        UIColor(Color.accentColor)
    }
}

extension UIListContentConfiguration {
    static func compactibleProminentInsetGroupedHeader() -> UIListContentConfiguration {
        if #available(iOS 15.0, *) {
            return .prominentInsetGroupedHeader()
        } else {
            return .groupedHeader()
        }
    }
}

extension UIView {
    func subviews<T: UIView>(ofType WhatType: T.Type) -> [T] {
        var result = subviews.compactMap { $0 as? T }
        
        for sub in subviews {
            result.append(contentsOf: sub.subviews(ofType: WhatType))
        }
        
        return result
    }
    
    var firstTextField: UITextField? {
        subviews(ofType: UITextField.self).first
    }
    
    var isFirstResponderInSubviews: Bool {
        subviews(ofType: UITextField.self).contains { $0.isFirstResponder } ||
            subviews(ofType: UITextView.self).contains { $0.isFirstResponder }
    }
    
    var firstResponder: UIView? {
        subviews(ofType: UITextField.self).first { $0.isFirstResponder } ??
            subviews(ofType: UITextView.self).first { $0.isFirstResponder }
    }
}
