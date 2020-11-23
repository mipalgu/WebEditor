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

struct IntegerView: View {

    @ObservedObject var machine: Ref<Machine>
    let path: Attributes.Path<Machine, Int>?
    let label: String
    
    @State var value: String
    
    @EnvironmentObject var config: Config
    
    init(machine: Ref<Machine>, path: Attributes.Path<Machine, Int>?, label: String, defaultValue: Int = 0) {
        self.machine = machine
        self.path = path
        self.label = label
        self._value = State(initialValue: path.map { String(machine[path: $0].value) } ?? String(defaultValue))
    }
    
    var body: some View {
        TextField(label, text: $value, onCommit: {
            guard let path = self.path else {
                return
            }
            guard let value = Int(value) else {
                return
            }
            do {
                try machine.value.modify(attribute: path, value: value)
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
