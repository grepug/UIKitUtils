//
//  TextEditorCellConfiguration.swift
//  Vision2-refactored
//
//  Created by Kai on 2021/8/7.
//

import UIKit
import TwitterTextEditor
import DiffableList

public struct TextEditorCellConfiguration: UIContentConfiguration {
    var text: String?
    var ph: String?
    var height: CGFloat
    var disabled: Bool?
    var action: ((String) -> Void)?
    
    public func makeContentView() -> UIView & UIContentView {
        View(configuration: self)
    }
    
    public func updated(for state: UIConfigurationState) -> TextEditorCellConfiguration {
        self
    }
}

extension TextEditorCellConfiguration {
    class View: UIView & UIContentView {
        typealias Config = TextEditorCellConfiguration
        
        var configuration: UIContentConfiguration {
            get {
                currentConfig
            }
            
            set {
                currentConfig = newValue as! Config
            }
        }
        
        var currentConfig: Config
        
        lazy var textEditor = TextEditorView()
        
        init(configuration: Config) {
            self.currentConfig = configuration
            
            super.init(frame: .zero)
            
            setupViews()
            apply()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

private extension TextEditorCellConfiguration.View {
    func setupViews() {
        addSubview(textEditor)
        textEditor.editingDelegate = self
        textEditor.editingContentDelegate = self
        textEditor.font = .preferredFont(forTextStyle: .body)
        textEditor.placeholderTextColor = .placeholderText
        textEditor.maximumNumberOfLinesForPlaceholderText = 2
        textEditor.scrollView.alwaysBounceVertical = false
        textEditor.addDoneButton()
        
        let config = configuration as! Config

        textEditor.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textEditor.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textEditor.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            textEditor.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8),
            textEditor.heightAnchor.constraint(equalToConstant: config.height)
        ])
    }
    
    func apply() {
        let config = currentConfig
        
        textEditor.text = config.text ?? ""
        textEditor.placeholderText = config.ph
        textEditor.isEditable = config.disabled != true
        textEditor.isSelectable = config.disabled != true
        textEditor.textColor = config.disabled == true ? .secondaryLabel : .label
    }
}

extension TextEditorCellConfiguration.View: TextEditorViewEditingDelegate, TextEditorViewEditingContentDelegate {
    func textEditorViewShouldBeginEditing(_ textEditorView: TextEditorView) -> Bool {
        true
    }
    
    func textEditorViewDidBeginEditing(_ textEditorView: TextEditorView) {
        
    }
    
    func textEditorViewDidEndEditing(_ textEditorView: TextEditorView) {
        (configuration as! Config).action?(textEditorView.text)
    }
    
    func textEditorView(_ textEditorView: TextEditorView, updateEditingContent editingContent: TextEditorViewEditingContent) -> TextEditorViewEditingContent? {
        let text = editingContent.text
        currentConfig.text = text
        
        #if targetEnvironment(macCatalyst)
        (configuration as! Config).action?(textEditorView.text)
        #endif
        
        return editingContent
    }
}

extension TextEditorView {
    func addDoneButton() {
        inputAccessoryView = .makeDoneButton(inputView: self)
    }
}

public extension DLContentConfiguration {
    static func textEditor(text: String?, placeholder: String?, height: CGFloat = 240, disabled: Bool = false, action: ((String) -> Void)? = nil) -> Self {
        .init(contentConfiguration: TextEditorCellConfiguration(text: text, ph: placeholder, height: height, disabled: disabled, action: action))
    }
}
