//
//  UIViewController+Utils.swift
//  Vision 3 (iOS)
//
//  Created by Kai on 2022/2/9.
//

import UIKit
import Combine

public extension UIViewController {
    func push(_ vc: UIViewController, animated: Bool = true) {
        if let nav = self as? UINavigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            navigationController?.pushViewController(vc, animated: animated)
        }
    }
    
    func contains(_ vc: UIViewController) -> Bool {
        if let navC = self as? UINavigationController {
            return navC.viewControllers.contains(vc)
        }
        
        return self == vc || (navigationController?.viewControllers.contains(vc) ?? false)
    }
}

public extension UIViewController {
    func presentAlertController(title: String?, message: String?, alignment: UIAlertController.AlertMessageAlignmentConfig? = nil, actions: [UIAlertAction]) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let config = alignment {
            ac.setMessageAlignment(config)
        }
        
        actions.forEach { ac.addAction($0) }
        
        present(ac, animated: true)
    }
}

public extension UIAlertAction {
    static var cancel: UIAlertAction {
        .init(title: "action_cancel".loc, style: .cancel)
    }
    
    static func cancel(action: @escaping () -> Void) -> UIAlertAction {
        .init(title: "action_cancel".loc, style: .cancel, handler: { _ in
            action()
        })
    }
    
    static func delete(action: @escaping () -> Void) -> UIAlertAction {
        .init(title: "action_discard".loc, style: .destructive, handler: { _ in
            action()
        })
    }
    
    static func ok(style: UIAlertAction.Style = .default, action: (() -> Void)? = nil) -> UIAlertAction {
        .init(title: "action_ok".loc, style: style, handler: { _ in
            action?()
        })
    }
}

public extension UIViewController {
    func setupKeyboardSubscribers(scrollView: UIScrollView,
                                  storeIn cancellables: inout Set<AnyCancellable>,
                                  predicate: ((UIView?) -> IndexPath?)? = nil,
                                  onPopup: ((IndexPath) -> Void)? = nil)  {
        let keyboardUseCases = KeyboardUseCase()
        var originalContentInset: UIEdgeInsets = .zero
        
        keyboardUseCases
            .keyboardHeightPublisher
            .merge(with: keyboardUseCases
                    .keyboardWillHidePublisher
                    .map { _ in 0 }
            )
            .removeDuplicates()
            .index(0)
            .sink { [weak self] height, index in
                guard let self = self,
                      self.view.isFirstResponderInSubviews,
                      let indexPath = predicate?(self.view.firstResponder) else { return }
                
                if index == 0 {
                    originalContentInset = scrollView.contentInset
                }

                if height > 0 {
                    var contentInset = originalContentInset
                    
                    contentInset.bottom = height + 20
                    scrollView.contentInset = contentInset

                    onPopup?(indexPath)
                } else {
                    scrollView.contentInset = originalContentInset
                }
            }
            .store(in: &cancellables)
    }
}

public extension UIAlertController {
    struct AlertMessageAlignmentConfig {
        public init(alignment: NSTextAlignment = .left, font: UIFont = .preferredFont(forTextStyle: .subheadline), textColor: UIColor = .label, attributedString: NSAttributedString? = nil) {
            self.alignment = alignment
            self.font = font
            self.textColor = textColor
            self.attributedString = attributedString
        }
        
        var alignment: NSTextAlignment = .left
        var font: UIFont = .preferredFont(forTextStyle: .subheadline)
        var textColor: UIColor = .label
        var attributedString: NSAttributedString?
    }
    
    func setMessageAlignment(_ config: AlertMessageAlignmentConfig = .init()) {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.alignment = config.alignment
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        let messageText = NSMutableAttributedString(
            string: self.message ?? "",
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: config.font,
                NSAttributedString.Key.foregroundColor: config.textColor
            ]
        )
        
        if let string = config.attributedString {
            messageText.append(string)
        }
        
        self.setValue(messageText, forKey: "attributedMessage")
    }
}

public extension UIViewController {
    func navigationControllerWrapped() -> UINavigationController {
        .init(rootViewController: self)
    }
}

public extension UIViewController {
    func makeDoneButton(action: @escaping () -> Void) -> UIBarButtonItem {
        .init(systemItem: .done, primaryAction: .init { [unowned self] _ in
            view.endEditing(true)
            
            DispatchQueue.main.async {
                action()
            }
        })
    }
}

public extension UIBarButtonItem {
    func makeDoneButton(on vc: UIViewController, action: @escaping () -> Void) -> UIBarButtonItem {
        .init(systemItem: .done, primaryAction: .init { [unowned vc] _ in
            vc.view.endEditing(true)
            
            DispatchQueue.main.async {
                action()
            }
        })
    }
}

extension Publisher {
    func index(_ initial: Self.Output) -> AnyPublisher<(Self.Output, Int), Self.Failure> {
        scan((initial, -1)) { prev, cur in
            (cur, prev.1 + 1)
        }
        .eraseToAnyPublisher()
    }
}
