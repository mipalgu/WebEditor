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

public struct ExpressionView: View {
    
    @ObservedObject var value: Ref<Expression>
    @StateObject var viewModel: AttributeViewModel<Expression>
    let label: String
    let language: Language
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, Expression>, label: String, language: Language) {
        self.init(value: root[path: path], viewModel: AttributeViewModel(root: root, path: path), label: label, language: language)
    }
    
    init(value: Ref<Expression>, label: String, language: Language) {
        self.init(value: value, viewModel: AttributeViewModel(reference: value), label: label, language: language)
    }
    
    init(value: Ref<Expression>, viewModel: AttributeViewModel<Expression>, label: String, language: Language) {
        self.value = value
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.label = label
        self.language = language
    }
    
    public var body: some View {
        TextField(label, text: $viewModel.value, onCommit: viewModel.sendModification)
            .font(.body)
            .background(config.fieldColor)
            .foregroundColor(config.textColor)
            .onChange(of: value.value) {
                viewModel.value = $0
            }
    }
}
