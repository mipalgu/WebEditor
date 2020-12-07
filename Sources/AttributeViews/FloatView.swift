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

import Machines
import Attributes
import Utilities

public struct FloatView<Root: Modifiable>: View {

    @ObservedObject var root: Ref<Root>
    let path: Attributes.Path<Root, Double>?
    let label: String
    
    @State var value: String
    
    @EnvironmentObject var config: Config
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, Double>?, label: String, defaultValue: Double = 0.0) {
        self.root = root
        self.path = path
        self.label = label
        self._value = State(initialValue: path.map { String(root[path: $0].value) } ?? String(defaultValue))
    }
    
    public var body: some View {
        TextField(label, text: $value, onCommit: {
            guard let path = self.path else {
                return
            }
            guard let value = Double(value) else {
                return
            }
            do {
                try root.value.modify(attribute: path, value: value)
                return
            } catch let e {
                print("\(e)")
            }
            self.value = String(root[path: path].value)
        })
        .font(.body)
        .background(config.fieldColor)
        .foregroundColor(config.textColor)
    }
}
