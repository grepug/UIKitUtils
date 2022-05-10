//
//  KeyboardUseCases.swift
//  Vision2-refactored
//
//  Created by Kai on 2021/6/2.
//

import Combine
import UIKit

struct KeyboardUseCase {
    var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .throttle(for: 0.3, scheduler: RunLoop.main, latest: true)
            .compactMap { notification -> CGFloat? in
                guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return nil }
                let keyboardHeight = CGFloat(keyboardSize.height)
                
                return keyboardHeight
            }
            .eraseToAnyPublisher()
    }
    
    var keyboardWillHidePublisher: AnyPublisher<Void, Never> {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    var keyboardDidHidePublisher: AnyPublisher<Void, Never> {
        NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    var keyboardShowingPublisher: AnyPublisher<Bool, Never> {
        keyboardHeightPublisher
            .map { _ in true }
            .merge(with: keyboardWillHidePublisher.map { _ in false })
            .eraseToAnyPublisher()
    }
}
