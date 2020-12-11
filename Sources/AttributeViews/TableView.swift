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

final class TableViewModel: AttributeViewModel<[[LineAttribute]]> {
    
    @Published var newRow: [Ref<LineAttribute>]
    
    init<Root>(root: Ref<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, columns: [BlockAttributeType.TableColumn]) where Root : Modifiable {
        self.newRow = columns.map { Ref(copying: $0.type.defaultValue) }
        super.init(root: root, path: path)
        newRow.forEach(self.listen)
    }
    
    init(reference ref: Ref<[[LineAttribute]]>, columns: [BlockAttributeType.TableColumn]) {
        self.newRow = columns.map { Ref(copying: $0.type.defaultValue) }
        super.init(reference: ref)
        newRow.forEach(self.listen)
    }
    
    func addElement() {}
    
    func moveElements(fromOffsets source: IndexSet, to destination: Int) {}
    
    func deleteElements(atOffsets offsets: IndexSet) {}
    
}

public struct TableView<Root: Modifiable>: View {
    
    @ObservedObject var root: Ref<Root>
    @StateObject var viewModel: TableViewModel
    let subView: (TableView, Int) -> TableRowView
    let label: String
    let columns: [BlockAttributeType.TableColumn]
    
    @EnvironmentObject var config: Config
    
    @State var selection: Set<Int> = []
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        self.init(root: root, viewModel: TableViewModel(root: root, path: path, columns: columns), label: label, columns: columns) {
            TableRowView(root: root, path: path[$1], row: $0.$viewModel.value[$1])
        }
    }
    
    init(root: Ref<Root>, value: Ref<[[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        self.init(root: root, viewModel: TableViewModel(reference: value, columns: columns), label: label, columns: columns) {
            TableRowView(value: value[$1], row: $0.$viewModel.value[$1])
        }
    }
    
    init(root: Ref<Root>, viewModel: TableViewModel, label: String, columns: [BlockAttributeType.TableColumn], subView: @escaping (TableView, Int) -> TableRowView) {
        self.root = root
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.subView = subView
        self.label = label
        self.columns = columns
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(label.pretty.capitalized)
                .font(.headline)
                .foregroundColor(config.textColor)
            List(selection: $selection) {
                HStack {
                    ForEach(Array(columns.indices), id: \.self) { index in
                        Text(columns[index].name.pretty)
                            .multilineTextAlignment(.leading)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    Text("").frame(width: 15)
                }
                HStack {
                    ForEach(viewModel.newRow) { attribute in
                        LineAttributeView(attribute: attribute, label: "")
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    Button(action: viewModel.addElement, label: {
                        Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                    }).buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
                    .frame(width: 15)
                }
                ForEach(Array(viewModel.value.indices), id: \.self) { rowIndex in
                    Divider()
                    HStack {
                        subView(self, rowIndex)
                        Text("").frame(width: 15)
                    }
                }.onMove(perform: viewModel.moveElements).onDelete(perform: viewModel.deleteElements)
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
    
    public init(value: Ref<[LineAttribute]>, row: Binding<[LineAttribute]>) {
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
