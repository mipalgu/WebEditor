//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 13/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Attributes
import Utilities

public struct CodeView<Label: View>: View {
    
    @ObservedObject var value: Ref<Code>
    @StateObject var viewModel: AttributeViewModel<Code>
    let label: () -> Label
    let language: Language
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, Code>, label: String, language: Language) where Label == Text {
        self.init(root: root, path: path, language: language, label: { Text(label.capitalized) })
    }
    
    init(value: Ref<Code>, label: String, language: Language) where Label == Text {
        self.init(value: value, language: language, label: { Text(label.capitalized) })
    }
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, Code>, language: Language, label: @escaping () -> Label) {
        self.init(value: root[path: path], viewModel: AttributeViewModel(root: root, path: path), language: language, label: label)
    }
    
    init(value: Ref<Code>, language: Language, label: @escaping () -> Label) {
        self.init(value: value, viewModel: AttributeViewModel(reference: value), language: language, label: label)
    }
    
    init(value: Ref<Code>, viewModel: AttributeViewModel<Code>, language: Language, label: @escaping () -> Label) {
        self.value = value
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.language = language
        self.label = label
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            label()
            TextEditor(text: $viewModel.value)
                .font(config.fontBody)
                .foregroundColor(config.textColor)
                .disableAutocorrection(true)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
                .frame(minHeight: 80)
                .onChange(of: value.value) {
                    viewModel.value = $0
                }.onChange(of: viewModel.value) { _ in
                    viewModel.sendModification()
                }
        }
    }
}
