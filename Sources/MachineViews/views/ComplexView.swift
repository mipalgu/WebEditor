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
        if let defaultValue = defaultValue {
            self._value = State(initialValue: path.map { machine.wrappedValue[keyPath: $0.keyPath] } ?? defaultValue)
            return
        }
        func computeDefaultValue(_ type: AttributeType) -> Attribute {
            switch type {
            case .line(let lineAttribute):
                switch lineAttribute {
                case .bool:
                    return .bool(false)
                case .enumerated(let validValues):
                    return .enumerated(validValues.first ?? "", validValues: validValues)
                case .expression(let language):
                    return .expression("", language: language)
                case .float:
                    return .float(0.0)
                case .integer:
                    return .integer(0)
                case .line:
                    return .line("")
                }
            case .block(let blockAttribute):
                switch blockAttribute {
                case .code(let language):
                    return .code("", language: language)
                case .collection(let type):
                    return .block(.collection([], type: type))
                case .complex(let fields):
                    let values = Dictionary(uniqueKeysWithValues: fields.map { (field) -> (Attributes.Label, Attribute) in
                        return (field.name, computeDefaultValue(field.type))
                    })
                    return .complex(values, layout: fields)
                case .enumerableCollection(let validValues):
                    return .enumerableCollection(Set(), validValues: validValues)
                case .table(let columns):
                    return .table([], columns: columns.map { ($0.name, $0.type) })
                case .text:
                    return .text("")
                }
            }
        }
        let defaultValue = computeDefaultValue(.complex(layout: fields)).complexValue
        self._value = State(initialValue: path.map { machine.wrappedValue[keyPath: $0.keyPath] } ?? defaultValue)
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
