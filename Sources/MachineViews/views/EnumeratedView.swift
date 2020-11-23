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

struct EnumeratedView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, String>?
    let label: String
    let validValues: Set<String>
    
    @State var value: String
    
    @EnvironmentObject var config: Config
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, String>?, label: String, validValues: Set<String>, defaultValue: String? = nil) {
        self._machine = machine
        self.path = path
        self.label = label
        self.validValues = validValues
        self._value = State(initialValue: path.map { machine.wrappedValue[keyPath: $0.keyPath] } ?? defaultValue ?? validValues.sorted().first ?? "")
    }
    
    var body: some View {
        Picker(label, selection: $value) {
            ForEach(validValues.sorted(), id: \.self) {
                Text($0).tag($0)
                    .foregroundColor(config.textColor)
            }
        }.pickerStyle(InlinePickerStyle())
        .onChange(of: value) {
            guard let path = self.path else {
                return
            }
            do {
                try machine.modify(attribute: path, value: $0)
                return
            } catch let e {
                print("\(e)")
            }
            self.value = machine[keyPath: path.keyPath]
        }
    }
}
