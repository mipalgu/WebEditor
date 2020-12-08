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

public struct TableView: View {
    
    @StateObject var viewModel: AttributeViewModel<[[LineAttribute]]>
    let subView: (TableView, Int) -> TableRowView
    let label: String
    let columns: [BlockAttributeType.TableColumn]
    
    @EnvironmentObject var config: Config
    
    @State var selection: Set<Int> = []
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        self.init(viewModel: AttributeViewModel(root: root, path: path), label: label, columns: columns) {
            TableRowView(root: root, path: path[$1], row: $0.$viewModel.value[$1])
        }
    }
    
    init(value: Binding<[[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        self.init(viewModel: AttributeViewModel(binding: value), label: label, columns: columns) {
            TableRowView(value: value[$1], row: $0.$viewModel.value[$1])
        }
    }
    
    init(viewModel: AttributeViewModel<[[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn], subView: @escaping (TableView, Int) -> TableRowView) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.subView = subView
        self.label = label
        self.columns = columns
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(label.capitalized)
                .font(.headline)
                .foregroundColor(config.textColor)
            List(selection: $selection) {
                HStack {
                    ForEach(Array(columns.indices), id: \.self) { index in
                        Text(columns[index].name.pretty)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                }
                ForEach(Array(viewModel.value.indices), id: \.self) { rowIndex in
                    subView(self, rowIndex)
                }
            }.frame(minHeight: 100)
        }
    }
}

struct TableRowView: View {
    
    let subView: (Int) -> LineAttributeView
    @Binding var row: [LineAttribute]
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, [LineAttribute]>, row: Binding<[LineAttribute]>) {
        self.subView = {
            LineAttributeView(root: root, path: path[$0], label: "")
        }
        self._row = row
    }
    
    public init(value: Binding<[LineAttribute]>, row: Binding<[LineAttribute]>) {
        self.subView = {
            LineAttributeView(attribute: value[$0], label: "")
        }
        self._row = row
    }
    
    var body: some View {
        HStack {
            ForEach(Array(row.indices), id: \.self) { columnIndex in
                subView(columnIndex)
            }
        }
    }
}
