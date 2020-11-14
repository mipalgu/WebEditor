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

struct AttributeGroupView<Path: PathProtocol>: View where Path.Root == Machine, Path.Value == AttributeGroup {
    
    @Binding var machine: Machine
    let path: Path
    let label: String
    let group: AttributeGroup
    
    @ViewBuilder var body: some View {
        ScrollView {
            VStack {
                Text(label.capitalized)
                ForEach(Array(group.fields.enumerated()), id: \.0) { (index, field) in
                    switch field.type {
                    case .line:
                        LineAttributeView(
                            machine: $machine,
                            path: Attributes.Path(
                                path: path.path.appending(path: \.attributes[field.name].wrappedValue),
                                ancestors: []
                            ),
                            label: field.name
                        )
                    case .block:
                        BlockAttributeView(
                            machine: $machine,
                            path: Attributes.Path(
                                path: path.path.appending(path: \.attributes[field.name].wrappedValue),
                                ancestors: []
                            ),
                            label: field.name
                        )
                    }
                }
            }
        }
    }
}
