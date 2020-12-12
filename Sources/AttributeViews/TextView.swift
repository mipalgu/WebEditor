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

public struct TextView: View {
    
    @ObservedObject var value: Ref<String>
    @StateObject var viewModel: AttributeViewModel<String>
    let label: String
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, String>, label: String) {
        self.init(value: root[path: path], viewModel: AttributeViewModel(root: root, path: path), label: label)
    }
    
    init(value: Ref<String>, label: String) {
        self.init(value: value, viewModel: AttributeViewModel(reference: value), label: label)
    }
    
    init(value: Ref<String>, viewModel: AttributeViewModel<String>, label: String) {
        self.value = value
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.label = label
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(label.capitalized)
                .font(.headline)
                .foregroundColor(config.textColor)
            TextEditor(text: $viewModel.value)
                .font(.body)
                .foregroundColor(config.textColor)
                .disableAutocorrection(false)
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
