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

public struct IntegerView: View {

    @StateObject var viewModel: AttributeViewModel<Int>
    let label: String
    
    @EnvironmentObject var config: Config
    
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        return formatter
    }
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, Int>, label: String) {
        self.init(viewModel: AttributeViewModel(root: root, path: path), label: label)
    }
    
    init(value: Ref<Int>, label: String) {
        self.init(viewModel: AttributeViewModel(reference: value), label: label)
    }
    
    init(viewModel: AttributeViewModel<Int>, label: String) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.label = label
    }
    
    public var body: some View {
        TextField(label, value: $viewModel.value, formatter: formatter, onCommit: viewModel.sendModification)
        .font(.body)
        .background(config.fieldColor)
        .foregroundColor(config.textColor)
    }
}
