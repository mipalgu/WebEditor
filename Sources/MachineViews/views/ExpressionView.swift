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

struct ExpressionView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Expression>?
    let label: String
    let language: Language
    
    @State var value: String
    
    @EnvironmentObject var config: Config
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Expression>?, label: String, language: Language, defaultValue: Expression = "") {
        self._machine = machine
        self.path = path
        self.label = label
        self.language = language
        self._value = State(initialValue: path.map { String(machine.wrappedValue[keyPath: $0.keyPath]) } ?? String(defaultValue))
    }
    
    var body: some View {
        TextField(label, text: $value, onCommit: {
            guard let path = self.path else {
                return
            }
            do {
                try machine.modify(attribute: path, value: Expression(value))
                return
            } catch let e {
                print("\(e)")
            }
            self.value = String(machine[keyPath: path.keyPath])
        })
        .font(.body)
        .background(config.fieldColor)
        .foregroundColor(config.textColor)
    }
}
