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
    let path: Attributes.Path<Machine, [String: Attribute]>
    let label: String
    let fields: [Field]
    
    var body: some View {
        Section(header: Text(label.capitalized).font(.title3)) {
            VStack(alignment: .leading) {
                ForEach(fields, id: \.name) { field in
                    AttributeView(machine: $machine, path: path[field.name].wrappedValue, label: field.name.pretty)
                }
            }.padding(10).background(Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.05))
        }
    }
}
