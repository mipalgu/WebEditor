//
//  ComplexView.swift
//  
//
//  Created by Morgan McColl on 16/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct ComplexView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, [Attributes.Label: Attribute]>?
    let label: String
    let fields: [Field]
    
    @State var value: [String: Attribute]
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, [String: Attribute]>?, label: String, fields: [Field], defaultValue: [Attributes.Label: Attribute]? = nil) {
        self._machine = machine
        self.path = path
        self.label = label
        self.fields = fields
        self._value = State(initialValue: path.map { machine.wrappedValue[keyPath: $0.keyPath] } ?? defaultValue ?? AttributeType.complex(layout: fields).defaultValue.complexValue)
    }
    
    var body: some View {
        Section(header: Text(label.capitalized).font(.title3)) {
            VStack(alignment: .leading) {
                ForEach(fields, id: \.name) { field in
                    AttributeView(
                        machine: $machine,
                        attribute: Binding(get: { self.value[field.name]! }, set: { self.value[field.name] = $0 }),
                        path: path?[field.name].wrappedValue,
                        label: field.name.pretty
                    )
                }
            }.padding(10).background(Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.05))
        }
    }
}
