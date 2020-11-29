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
import Utilities

public struct AttributeGroupView: View {
    
    @ObservedObject var machine: Ref<Machine>
    let path: Attributes.Path<Machine, AttributeGroup>
    let label: String
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, AttributeGroup>, label: String) {
        self.machine = machine
        self.path = path
        self.label = label
    }
    
    @ViewBuilder
    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Form {
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(Array(machine[path: path].fields.value.enumerated()), id: \.0) { (index, field) in
                            AttributeView(
                                machine: machine,
                                attribute: machine[path: path].attributes[field.name].wrappedValue.asBinding,
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
