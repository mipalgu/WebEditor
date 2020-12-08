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

public struct ComplexView: View {
    
    @StateObject var viewModel: AttributeViewModel<[String: Attribute]>
    let subView: (Field) -> AttributeView
    let label: String
    let fields: [Field]
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, [String: Attribute]>, label: String, fields: [Field]) {
        self.init(viewModel: AttributeViewModel(root: root, path: path), label: label, fields: fields) {
            AttributeView(root: root, path: path[$0.name].wrappedValue, label: $0.name.pretty)
        }
    }
    
    init(value: Binding<[String: Attribute]>, label: String, fields: [Field]) {
        self.init(viewModel: AttributeViewModel(binding: value), label: label, fields: fields) {
            AttributeView(attribute: Binding(value[$0.name])!, label: $0.name.pretty)
        }
    }
    
    init(viewModel: AttributeViewModel<[String: Attribute]>, label: String, fields: [Field], subView: @escaping (Field) -> AttributeView) {
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
