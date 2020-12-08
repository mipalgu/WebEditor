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

public struct LineView: AttributeViewProtocol {
    
    @StateObject var viewModel: AttributeViewModel<String>
    let label: String
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, String>, label: String) {
        self.init(viewModel: AttributeViewModel(root: root, path: path), label: label)
    }
    
    init(value: Binding<String>, label: String) {
        self.init(viewModel: AttributeViewModel(binding: value), label: label)
    }
    
    init(viewModel: AttributeViewModel<String>, label: String) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.label = label
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            TextField(label, text: $viewModel.value, onCommit: viewModel.sendModification)
            .background(config.fieldColor)
            .foregroundColor(config.textColor)
            if let error = self.viewModel.error {
                Text(error).foregroundColor(.red)
            }
        }
    }
}

import Machines

struct LineView_Preview: PreviewProvider {
    
    static let root: Ref<Machine> = Ref(copying: Machine.initialSwiftMachine())
    
    static var previews: some View {
        LineView(
            root: root,
            path: Machine.path.states[0].name,
            label: "State 0"
        ).environmentObject(Config())
    }
    
}
