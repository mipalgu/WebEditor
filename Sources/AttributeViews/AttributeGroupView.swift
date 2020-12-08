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

    @StateObject var viewModel: AttributeViewModel<AttributeGroup>
    let subView: (Field) -> AttributeView
    let label: String
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, AttributeGroup>, label: String) {
        self.init(viewModel: AttributeViewModel(root: root, path: path), label: label) { field in
            AttributeView(
                root: root,
                path: path.attributes[field.name].wrappedValue,
                label: field.name.pretty
            )
        }
    }
    
    init(group: Binding<AttributeGroup>, label: String) {
        self.init(viewModel: AttributeViewModel(binding: group), label: label) { field in
            AttributeView(attribute: Binding(group.attributes[field.name])!, label: field.name.pretty)
        }
    }
    
    init(viewModel: AttributeViewModel<AttributeGroup>, label: String, subView: @escaping (Field) -> AttributeView) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.subView = subView
        self.label = label
    }
    
    @ViewBuilder
    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Form {
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(Array(viewModel.value.fields.enumerated()), id: \.0) { (index, field) in
                            subView(field)
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}
