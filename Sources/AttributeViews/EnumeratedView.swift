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

public struct EnumeratedView: View {

    @StateObject var viewModel: AttributeViewModel<Expression>
    let label: String
    let validValues: Set<String>
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, Expression>, label: String, validValues: Set<String>) {
        self.init(viewModel: AttributeViewModel(root: root, path: path), label: label, validValues: validValues)
    }
    
    init(value: Ref<Expression>, label: String, validValues: Set<String>) {
        self.init(viewModel: AttributeViewModel(reference: value), label: label, validValues: validValues)
    }
    
    init(viewModel: AttributeViewModel<Expression>, label: String, validValues: Set<String>) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.label = label
        self.validValues = validValues
    }
    
    public var body: some View {
        Picker(label, selection: $viewModel.value) {
            ForEach(validValues.sorted(), id: \.self) {
                Text($0).tag($0)
                    .foregroundColor(config.textColor)
            }
        }.pickerStyle(InlinePickerStyle())
        .onChange(of: viewModel.value) { _ in
            self.viewModel.sendModification()
        }
    }
}
