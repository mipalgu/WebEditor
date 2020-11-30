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
    
    @Binding var group: AttributeGroup
    let label: String
    let onCommit: (AttributeGroup, Binding<String>) -> Void
    
    public init(group: Binding<AttributeGroup>, label: String, onCommit: @escaping (AttributeGroup, Binding<String>) -> Void = { (_, _) in }) {
        self._group = group
        self.label = label
        self.onCommit = onCommit
    }
    
    @ViewBuilder
    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            HStack {
                VStack(alignment: .leading) {
                    ForEach(Array(group.fields.enumerated()), id: \.0) { (index, field) in
                        AttributeView(
                            attribute: Binding($group.attributes[field.name])!,
                            label: field.name.pretty
                        ) { (_, error) in
                            self.onCommit(group, error)
                        }
                    }
                }
                Spacer()
            }
        }
    }
}
