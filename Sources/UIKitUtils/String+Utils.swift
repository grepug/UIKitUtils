//
//  File.swift
//  
//
//  Created by Kai on 2022/5/10.
//

import Foundation

extension String {
    var loc: Self {
        String(format: NSLocalizedString(self, bundle: .module, comment: ""), "")
    }
    
    func loc(_ string: String) -> Self {
        String(format: NSLocalizedString(self, bundle: .module, comment: ""), string)
    }
}
