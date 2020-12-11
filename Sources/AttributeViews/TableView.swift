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
    
    @Published var selection: Set<Int> = []
    
    let _addElement: (TableViewModel) -> Void
    let _deleteElement: (TableViewModel, Int) -> Void
    let _deleteElements: (TableViewModel, IndexSet) -> Void
    let _moveElements: (TableViewModel, IndexSet, Int) -> Void
    
    init<Root>(root: Ref<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, columns: [BlockAttributeType.TableColumn]) where Root : Modifiable {
        self._addElement = { me in
            do {
                try root.value.addItem(me.newRow.map(\.value), to: path)
                me.value = root[path: path].value
                me.newRow.forEach {
                    $0.value = $0.type.defaultValue.value
                }
                me.error = nil
            } catch let e as AttributeError<Root> where e.isError(forPath: path) {
                me.error = e.message
            } catch {}
        }
        self._deleteElement = { (me, index) in
            let offsets: IndexSet = me.selection.contains(index)
                ? IndexSet(me.value.enumerated().lazy.filter { me.selection.contains($0.offset) }.map { $0.0 })
                : [index]
            me.deleteElements(offsets: offsets)
        }
        self._deleteElements = { (me, offsets) in
            do {
                try root.value.deleteItems(table: path, items: offsets)
                me.value = root[path: path].value
                me.error = nil
            } catch let e as AttributeError<Root> where e.isError(forPath: path) {
                me.error = e.message
            } catch {}
        }
        self._moveElements = { (me, source, destination) in
            do {
                try root.value.moveItems(table: path, from: source, to: destination)
                me.value = root[path: path].value
                me.error = nil
            } catch let e as AttributeError<Root> where e.isError(forPath: path) {
                me.error = e.message
            } catch {}
        }
        self.newRow = columns.map { Ref(copying: $0.type.defaultValue) }
        super.init(root: root, path: path)
        newRow.forEach(self.listen)
    }
    
    init(reference ref: Ref<[[LineAttribute]]>, columns: [BlockAttributeType.TableColumn]) {
        self._addElement = { me in
            me.value.append(me.newRow.map(\.value))
            me.newRow.forEach {
                $0.value = $0.type.defaultValue.value
            }
        }
        self._deleteElement = { (me, index) in
            let offsets: IndexSet = me.selection.contains(index)
                ? IndexSet(me.value.enumerated().lazy.filter { me.selection.contains($0.offset) }.map { $0.0 })
                : [index]
            me.deleteElements(offsets: offsets)
        }
        self._deleteElements = { (me, offsets) in
            me.value.remove(atOffsets: offsets)
        }
        self._moveElements = { (me, source, destination) in
            me.value.move(fromOffsets: source, toOffset: destination)
        }
        self.newRow = columns.map { Ref(copying: $0.type.defaultValue) }
        super.init(reference: ref)
        newRow.forEach(self.listen)
    }
    
    func addElement() {
        self._addElement(self)
    }
    
    func moveElements(fromOffsets source: IndexSet, to destination: Int) {
        self._moveElements(self, source, destination)
    }
    
    func deleteElements(offsets: IndexSet) {
        self._deleteElements(self, offsets)
    }
    
    func deleteElement(atIndex index: Int) {
        self._deleteElement(self, index)
    }
    
}

public struct TableView<Root: Modifiable>: View {
    
    let root: Ref<Root>
    @StateObject var viewModel: TableViewModel
    let subView: (TableView, Int) -> TableRowView
    let label: String
    let columns: [BlockAttributeType.TableColumn]
    
    @EnvironmentObject var config: Config
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        self.init(root: root, viewModel: TableViewModel(root: root, path: path, columns: columns), label: label, columns: columns) { (me, index) in
            TableRowView(root: root, path: path[index], row: me.$viewModel.value[index]) {
                me.viewModel.deleteElement(atIndex: index)
            }
        }
    }
    
    init(root: Ref<Root>, value: Ref<[[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        let viewModel = TableViewModel(reference: value, columns: columns)
        self.init(root: root, viewModel: viewModel, label: label, columns: columns) { (me, index) in
            TableRowView(value: value[index], row: me.$viewModel.value[index]) {
                me.viewModel.deleteElement(atIndex: index)
            }
        }
    }
    
    private init(root: Ref<Root>, viewModel: TableViewModel, label: String, columns: [BlockAttributeType.TableColumn], subView: @escaping (TableView, Int) -> TableRowView) {
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
            List(selection: $viewModel.selection) {
                Section(header: VStack {
                    HStack {
                        ForEach(Array(columns.indices), id: \.self) { index in
                            Text(columns[index].name.pretty)
                                .multilineTextAlignment(.leading)
                                .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        Text("").frame(width: 15)
                    }
                    if let error = viewModel.error {
                        Text(error).foregroundColor(.red)
                    }
                }, content: {
                    ForEach(Array(viewModel.value.indices), id: \.self) { rowIndex in
                        subView(self, rowIndex)
                    }.onMove(perform: viewModel.moveElements).onDelete(perform: viewModel.deleteElements)
                })
            }.padding(.bottom, -15).frame(minHeight: CGFloat(30 * viewModel.value.count + 35))
            ScrollView([.vertical], showsIndicators: false) {
                HStack {
                    ForEach(viewModel.newRow) { attribute in
                        LineAttributeView(attribute: attribute, label: "")
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    Button(action: viewModel.addElement, label: {
                        Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                    }).buttonStyle(PlainButtonStyle())
                      .foregroundColor(.blue)
                      .frame(width: 15)
                }
            }.padding(.leading, 15).padding(.trailing, 18).frame(height: 50)
        }
    }
}

struct TableRowView: View {
    
    let subView: (Int) -> LineAttributeView
    @Binding var row: [LineAttribute]
    let onDelete: () -> Void
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, [LineAttribute]>, row: Binding<[LineAttribute]>, onDelete: @escaping () -> Void) {
        self.subView = {
            LineAttributeView(root: root, path: path[$0], label: "")
        }
        self._row = row
        self.onDelete = onDelete
    }
    
    public init(value: Ref<[LineAttribute]>, row: Binding<[LineAttribute]>, onDelete: @escaping () -> Void) {
        self.subView = {
            LineAttributeView(attribute: value[$0], label: "")
        }
        self._row = row
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack {
            ForEach(Array(row.indices), id: \.self) { columnIndex in
                subView(columnIndex)
            }
            Image(systemName: "ellipsis").font(.system(size: 16, weight: .regular)).rotationEffect(.degrees(90))
        }.contextMenu {
            Button("Delete", action: onDelete).keyboardShortcut(.delete)
        }
    }
}
