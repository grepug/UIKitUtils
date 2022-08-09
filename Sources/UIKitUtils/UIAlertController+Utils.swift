//
//  File.swift
//  
//
//  Created by Kai on 2022/8/9.
//

import UIKit

public extension UIViewController {
    func presentAlertController(title: String?,
                                message: String?,
                                alignment: UIAlertController.AlertMessageAlignmentConfig? = nil,
                                style: UIAlertController.Style = .alert,
                                barButtonItem: UIBarButtonItem? = nil,
                                actions: [UIAlertAction]) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: style)
        
        #if !targetEnvironment(macCatalyst)
        if let config = alignment {
            ac.setMessageAlignment(config)
        }
        #endif
        
        actions.forEach { ac.addAction($0) }
        
        ac.popoverPresentationController?.barButtonItem = barButtonItem
        
        present(ac, animated: true)
    }
    
    struct ActionValue: Identifiable, Equatable {
        public init(id: String = UUID().uuidString, title: String, style: UIAlertAction.Style) {
            self.id = id
            self.title = title
            self.style = style
        }
        
        public var id: String
        var title: String
        var style: UIAlertAction.Style
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
        
        public static func ~= (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
        
        func alertAction(handler: @escaping () -> Void) -> UIAlertAction {
            .init(title: title, style: style, handler: { _ in handler() })
        }
        
        public static let cancel: Self = .init(title: "action_cancel".loc, style: .cancel)
        public static let ok: Self = .init(title: "action_ok".loc, style: .default)
        public static let delete: Self = .init(title: "action_discard".loc, style: .destructive)
    }
    
    func presentAlertController(title: String?,
                                message: String?,
                                alignment: UIAlertController.AlertMessageAlignmentConfig? = nil,
                                style: UIAlertController.Style = .alert,
                                barButtonItem: UIBarButtonItem? = nil,
                                actions: [ActionValue]) async -> ActionValue {
        await withCheckedContinuation { [unowned self] continuation in
            DispatchQueue.main.async { [unowned self] in
                presentAlertController(title: title,
                                       message: message,
                                       alignment: alignment,
                                       style: style,
                                       barButtonItem: barButtonItem,
                                       actions: actions.map { action in action.alertAction {
                    continuation.resume(returning: action)
                }})
            }
        }
    }
}

public extension UIAlertAction {
    static var cancelLocaizableString: String {
        "action_cancel".loc
    }
    
    static var deleteLocalizableString: String {
        "action_discard".loc
    }
    
    static var okLocalizableString: String {
        "action_ok".loc
    }
    
    static var cancel: UIAlertAction {
        .init(title: Self.cancelLocaizableString, style: .cancel)
    }
    
    static func cancel(action: @escaping () -> Void) -> UIAlertAction {
        .init(title: Self.cancelLocaizableString, style: .cancel, handler: { _ in
            action()
        })
    }
    
    static func delete(action: @escaping () -> Void) -> UIAlertAction {
        .init(title: Self.deleteLocalizableString, style: .destructive, handler: { _ in
            action()
        })
    }
    
    static func ok(style: UIAlertAction.Style = .default, action: (() -> Void)? = nil) -> UIAlertAction {
        .init(title: Self.okLocalizableString, style: style, handler: { _ in
            action?()
        })
    }
}
