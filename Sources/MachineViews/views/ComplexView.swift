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
        Section(header: Text(label.capitalized)) {
            ForEach(fields, id: \.name) { field in
                AttributeView(machine: $machine, path: path[field.name].wrappedValue, label: field.name)
            }
        }
    }
}
