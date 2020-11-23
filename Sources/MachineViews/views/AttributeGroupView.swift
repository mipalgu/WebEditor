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

struct AttributeGroupView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, AttributeGroup>
    let label: String
    
    @ViewBuilder
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Form {
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(Array(machine[keyPath: path.keyPath].fields.enumerated()), id: \.0) { (index, field) in
                            AttributeView(
                                machine: $machine,
                                attribute: Binding(get: { machine[keyPath: path.path].attributes[field.name]! }, set: { machine[keyPath: path.path].attributes[field.name] = $0 }),
                                path: path.attributes[field.name].wrappedValue,
                                label: field.name.pretty
                            )
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}
