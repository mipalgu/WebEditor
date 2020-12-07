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

public struct BoolView<Root: Modifiable>: View {
    
    @ObservedObject var root: Ref<Root>
    let path: Attributes.Path<Root, Bool>?
    let label: String
    
    @Binding var value: Bool
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, Bool>?, label: String, defaultValue: Bool = false) {
        self.root = root
        self.path = path
        self.label = label
        if let path = path {
            self._value = root[bindingTo: path]
        } else {
            self._value = Ref(copying: false).asBinding
        }
    }
    
    @EnvironmentObject var config: Config
    
    public var body: some View {
        Toggle(label, isOn: $value)
            .animation(.easeOut)
            .font(.body)
            .foregroundColor(config.textColor)
            .onChange(of: value) {
                guard let path = self.path else {
                    return
                }
                do {
                    try root.value.modify(attribute: path, value: $0)
                    return
                } catch let e {
                    print("\(e)")
                }
                value = root[path: path].value
            }
    }
}

