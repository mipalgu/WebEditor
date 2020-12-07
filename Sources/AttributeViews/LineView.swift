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

public struct LineView<Root: Modifiable>: AttributeViewProtocol {
    
    @ObservedObject var root: Ref<Root>
    let path: Attributes.Path<Root, String>?
    let label: String
    let onChange: (String) -> Void
    
    @State var value: String
    
    @EnvironmentObject var config: Config
    
    @State var error: String? = nil
    
    var valueBinding: Binding<String> { $value }
    
    var errorBinding: Binding<String?> { $error }
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, String>?, label: String, defaultValue: String = "", onChange: @escaping (String) -> Void = { _ in }) {
        self.root = root
        self.path = path
        self.label = label
        self._value = State(initialValue: path.map { root[path: $0].value } ?? defaultValue)
        self.onChange = onChange
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            TextField(label, text: $value, onCommit: modify)
            .background(config.fieldColor)
            .foregroundColor(config.textColor)
            if let error = self.error {
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
