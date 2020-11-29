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

public struct ExpressionView: View {
    
    @ObservedObject var machine: Ref<Machine>
    let path: Attributes.Path<Machine, Expression>?
    let label: String
    let language: Language
    
    @State var value: String
    
    @EnvironmentObject var config: Config
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, Expression>?, label: String, language: Language, defaultValue: Expression = "") {
        self.machine = machine
        self.path = path
        self.label = label
        self.language = language
        self._value = State(initialValue: path.map { String(machine[path: $0].value) } ?? String(defaultValue))
    }
    
    public var body: some View {
        TextField(label, text: $value, onCommit: {
            guard let path = self.path else {
                return
            }
            do {
                try machine.value.modify(attribute: path, value: Expression(value))
                return
            } catch let e {
                print("\(e)")
            }
            self.value = String(machine[path: path].value)
        })
        .font(.body)
        .background(config.fieldColor)
        .foregroundColor(config.textColor)
    }
}
