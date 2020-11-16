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
            HStack {
                VStack(alignment: .leading) {
                    ForEach(Array(machine[keyPath: path.keyPath].fields.enumerated()), id: \.0) { (index, field) -> AnyView in
                        switch field.type {
                        case .line:
                            return AnyView(LineAttributeView(
                                machine: $machine,
                                path: path.attributes[field.name].wrappedValue.lineAttribute,
                                label: field.name
                            ))
                        case .block:
                            return AnyView(BlockAttributeView(
                                machine: $machine,
                                path: path.attributes[field.name].wrappedValue.blockAttribute,
                                label: field.name
                            ))
                        }
                    }
                }
                Spacer()
            }
        }
    }
}
