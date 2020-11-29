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
    
    @Binding var value: [String: Attribute]
    let label: String
    let fields: [Field]
    let onCommit: ([String: Attribute], Binding<String>) -> Void
    
    public init(value: Binding<[String: Attribute]>, label: String, fields: [Field], onCommit: @escaping ([String: Attribute], Binding<String>) -> Void = { (_, _) in }) {
        self._value = value
        self.label = label
        self.fields = fields
        self.onCommit = onCommit
    }
    
    public var body: some View {
        if !fields.isEmpty {
            Section(header: Text(label.capitalized).font(.title3)) {
                VStack(alignment: .leading) {
                    ForEach(fields, id: \.name) { field in
                        AttributeView(
                            attribute: Binding($value[field.name])!,
                            label: field.name.pretty
                        ) { (_, error) in
                            self.onCommit(value, error)
                        }
                    }
                }.padding(10).background(Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.05))
            }
        }
    }
}
