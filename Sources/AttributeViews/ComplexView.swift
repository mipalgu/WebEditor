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
    @StateObject var viewModel: AttributeViewModel<[String: Attribute]>
    let subView: (Field) -> AttributeView<Root>
    let label: String
    let fields: [Field]
    
    @EnvironmentObject var config: Config
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, [String: Attribute]>, label: String, fields: [Field]) {
        self.init(root: root, viewModel: AttributeViewModel(root: root, path: path), label: label, fields: fields) {
            AttributeView(root: root, path: path[$0.name].wrappedValue, label: $0.name.pretty)
        }
    }
    
    init(root: Ref<Root>, value: Ref<[String: Attribute]>, label: String, fields: [Field]) {
        self.init(root: root, viewModel: AttributeViewModel(reference: value), label: label, fields: fields) {
            AttributeView(root: root, attribute: value[$0.name].wrappedValue, label: $0.name.pretty)
        }
    }
    
    init(root: Ref<Root>, viewModel: AttributeViewModel<[String: Attribute]>, label: String, fields: [Field], subView: @escaping (Field) -> AttributeView<Root>) {
        self.root = root
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.subView = subView
        self.label = label
        self.fields = fields
    }
    
    public var body: some View {
        if !fields.isEmpty {
            Section(header: Text(label.capitalized).font(.title3)) {
                VStack(alignment: .leading) {
                    ForEach(fields, id: \.name) { field in
                        subView(field)
                    }
                }.padding(10).background(Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.05))
            }
        }
    }
}
