//
//  LineBoolView.swift
//  TokamakApp
//
//  Created by Morgan McColl on 12/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Attributes
import Utilities

public struct BoolView: View {
    
    @StateObject var viewModel: AttributeViewModel<Bool>
    let label: String
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, Bool>, label: String) {
        self.init(viewModel: AttributeViewModel(root: root, path: path), label: label)
    }
    
    public init(value: Binding<Bool>, label: String) {
        self.init(viewModel: AttributeViewModel(binding: value), label: label)
    }
    
    init(viewModel: AttributeViewModel<Bool>, label: String) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.label = label
    }
    
    public var body: some View {
        Toggle(label, isOn: $viewModel.value)
            .animation(.easeOut)
            .font(.body)
            .foregroundColor(config.textColor)
            .onChange(of: viewModel.value) { _ in
                viewModel.sendModification()
            }
    }
}

