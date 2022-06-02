//
//  UIImage+Utils.swift
//  
//
//  Created by Kai on 2022/6/2.
//

import UIKit

public extension UIImage {
    func colored(_ color: UIColor? = nil) -> UIImage {
        withTintColor(color ?? .placeholderText,
                      renderingMode: .alwaysOriginal)
    }
}
