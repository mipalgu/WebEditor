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

import Attributes
import Utilities

public struct AttributeGroupView<Root: Modifiable>: View {

    let root: Ref<Root>
    @ObservedObject var fields: Ref<[Field]>
    let path: Attributes.Path<Root, AttributeGroup>
    let label: String
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, AttributeGroup>, label: String) {
        self.root = root
        self.fields = root[path: path].fields
        self.path = path
        self.label = label
    }
    
    @ViewBuilder
    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Form {
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(Array(fields.value.indices).map { root[path: path].fields[$0] }, id: \.id) { element in
                            AttributeView(
                                root: root,
                                path: path.attributes[element.value.name].wrappedValue,
                                label: element.value.name.pretty
                            )
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}
