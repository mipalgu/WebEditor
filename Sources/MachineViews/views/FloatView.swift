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

struct FloatView: View {

    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Double>?
    let label: String
    
    @State var value: String
    
    @EnvironmentObject var config: Config
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Double>?, label: String, defaultValue: Double = 0.0) {
        self._machine = machine
        self.path = path
        self.label = label
        self._value = State(initialValue: path.map { String(machine.wrappedValue[keyPath: $0.keyPath]) } ?? String(defaultValue))
    }
    
    var body: some View {
        TextField(label, text: $value, onCommit: {
            guard let path = self.path else {
                return
            }
            guard let value = Double(value) else {
                return
            }
            do {
                try machine.modify(attribute: path, value: value)
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
