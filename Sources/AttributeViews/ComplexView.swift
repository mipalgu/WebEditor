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

import Attributes
import Utilities

public struct ComplexView<Root: Modifiable>: View {
    
    @ObservedObject var root: Ref<Root>
    let path: Attributes.Path<Root, [Attributes.Label: Attribute]>?
    let label: String
    let fields: [Field]
    
    @State var value: [String: Attribute]
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, [String: Attribute]>?, label: String, fields: [Field], defaultValue: [Attributes.Label: Attribute]? = nil) {
        self.root = root
        self.path = path
        self.label = label
        self.fields = fields
        self._value = State(initialValue: path.map { root[path: $0].value } ?? defaultValue ?? AttributeType.complex(layout: fields).defaultValue.complexValue)
    }
    
    public var body: some View {
        if !fields.isEmpty {
            Section(header: Text(label.capitalized).font(.title3)) {
                VStack(alignment: .leading) {
                    ForEach(fields, id: \.name) { field in
                        AttributeView(
                            root: root,
                            attribute: path.map { root[path: $0][field.name].wrappedValue.asBinding } ?? Binding($value[field.name])!,
                            path: path?[field.name].wrappedValue,
                            label: field.name.pretty
                        )
                    }
                }.padding(10).background(Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.05))
            }
        }
    }
}
