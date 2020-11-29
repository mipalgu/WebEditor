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
import Utilities

public struct ComplexView: View {
    
    @ObservedObject var machine: Ref<Machine>
    let path: Attributes.Path<Machine, [Attributes.Label: Attribute]>?
    let label: String
    let fields: [Field]
    
    @State var value: [String: Attribute]
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, [String: Attribute]>?, label: String, fields: [Field], defaultValue: [Attributes.Label: Attribute]? = nil) {
        self.machine = machine
        self.path = path
        self.label = label
        self.fields = fields
        self._value = State(initialValue: path.map { machine[path: $0].value } ?? defaultValue ?? AttributeType.complex(layout: fields).defaultValue.complexValue)
    }
    
    public var body: some View {
        if !fields.isEmpty {
            Section(header: Text(label.capitalized).font(.title3)) {
                VStack(alignment: .leading) {
                    ForEach(fields, id: \.name) { field in
                        AttributeView(
                            machine: machine,
                            attribute: path.map { machine[path: $0][field.name].wrappedValue.asBinding } ?? Binding($value[field.name])!,
                            path: path?[field.name].wrappedValue,
                            label: field.name.pretty
                        )
                    }
                }.padding(10).background(Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.05))
            }
        }
    }
}
