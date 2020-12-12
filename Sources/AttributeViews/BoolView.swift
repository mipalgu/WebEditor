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
    
    @ObservedObject var value: Ref<Bool>
    @StateObject var viewModel: AttributeViewModel<Bool>
    let label: String
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, Bool>, label: String) {
        self.init(value: root[path: path], viewModel: AttributeViewModel(root: root, path: path), label: label)
    }
    
    init(value: Ref<Bool>, label: String) {
        self.init(value: value, viewModel: AttributeViewModel(reference: value), label: label)
    }
    
    init(value: Ref<Bool>, viewModel: AttributeViewModel<Bool>, label: String) {
        print("init")
        self.value = value
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.label = label
    }
    
    public var body: some View {
        Toggle(label, isOn: $viewModel.value)
            .animation(.easeOut)
            .font(.body)
            .foregroundColor(config.textColor)
            .onChange(of: value.value) {
                viewModel.value = $0
            }.onChange(of: viewModel.value) { _ in
                viewModel.sendModification()
            }
    }
}

