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

public struct ExpressionView<Root: Modifiable>: View {
    
    @ObservedObject var root: Ref<Root>
    let path: Attributes.Path<Root, Expression>?
    let label: String
    let language: Language
    
    @State var value: String
    
    @EnvironmentObject var config: Config
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, Expression>?, label: String, language: Language, defaultValue: Expression = "") {
        self.root = root
        self.path = path
        self.label = label
        self.language = language
        self._value = State(initialValue: path.map { String(root[path: $0].value) } ?? String(defaultValue))
    }
    
    public var body: some View {
        TextField(label, text: $value, onCommit: {
            guard let path = self.path else {
                return
            }
            do {
                try root.value.modify(attribute: path, value: Expression(value))
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
