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

final class TableViewModel: ObservableObject {
    
    var value: [ListElement<[LineAttribute]>] {
        get {
            rootValue
        } set {
            self.objectWillChange.send()
            self.rootValue = newValue
        }
    }
    
    @Reference var rootValue: [ListElement<[LineAttribute]>]
    
    @Published var errors: [String]
    
    @Published var newRow: [Ref<LineAttribute>]
    
    @Published var selection: Set<UUID> = []
    
    let _addElement: (TableViewModel) -> Void
    let _deleteElements: (TableViewModel, IndexSet) -> Void
    let _moveElements: (TableViewModel, IndexSet, Int) -> Void
    let _errorsForItem: (TableViewModel, Int, Int) -> [String]
    let _latestValue: () -> [[LineAttribute]]
    
    init<Root>(root: Ref<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, columns: [BlockAttributeType.TableColumn]) where Root : Modifiable {
        self._addElement = { me in
            let result: ()? = try? root.value.addItem(me.newRow.map(\.value), to: path)
            me.update()
            me.errors = root.value.errorBag.errors(includingDescendantsForPath: path).map(\.message)
            if nil != result {
                root.objectWillChange.send()
                me.newRow.forEach {
                    $0.value = $0.type.defaultValue.value
                }
            }
        }
        self._deleteElements = { (me, offsets) in
            let result: ()? = try? root.value.deleteItems(table: path, items: offsets)
            me.update()
            me.errors = root.value.errorBag.errors(includingDescendantsForPath: path).map(\.message)
            if nil != result {
                root.objectWillChange.send()
            }
        }
        self._moveElements = { (me, source, destination) in
            let result: ()? = try? root.value.moveItems(table: path, from: source, to: destination)
            me.update()
            me.errors = root.value.errorBag.errors(includingDescendantsForPath: path).map(\.message)
            if nil != result {
                root.objectWillChange.send()
            }
        }
        self._errorsForItem = { (me, row, col) in
            return root.value.errorBag.errors(forPath: AnyPath(path[row][col])).map(\.message)
        }
        self._latestValue = { root[path: path].value }
        self.newRow = columns.map { Ref(copying: $0.type.defaultValue) }
        self._rootValue = Reference(wrappedValue: root[path: path].value.map { ListElement($0) })
        self.errors = root.value.errorBag.errors(includingDescendantsForPath: path).map(\.message)
    }
    
    init(reference ref: Ref<[[LineAttribute]]>, columns: [BlockAttributeType.TableColumn]) {
        self._addElement = { me in
            ref.value.append(me.newRow.map(\.value))
            me.newRow.forEach {
                $0.value = $0.type.defaultValue.value
            }
            me.update()
        }
        self._deleteElements = { (me, offsets) in
            ref.value.remove(atOffsets: offsets)
            me.update()
        }
        self._moveElements = { (me, source, destination) in
            ref.value.move(fromOffsets: source, toOffset: destination)
            me.update()
        }
        self._errorsForItem = { (_, _, _) in [] }
        self._latestValue = { ref.value }
        self.newRow = columns.map { Ref(copying: $0.type.defaultValue) }
        self._rootValue = Reference(wrappedValue: ref.value.map { ListElement($0) })
        self.errors = []
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
    
    func deleteElement(atIndex index: Int, withUUID uuid: UUID) {
        let offsets: IndexSet = self.selection.contains(uuid)
            ? IndexSet(self.value.enumerated().lazy.filter { self.selection.contains($1.id) }.map { $0.0 })
            : [index]
        self.deleteElements(offsets: offsets)
    }
    
    func errorsForItem(atRow row: Int, col: Int) -> [String] {
        self._errorsForItem(self, row, col)
    }
    
    func update() {
        let value = self._latestValue()
        if self.value.count > value.count {
            self.value = Array(self.value[0..<value.count])
        }
        zip(self.value, value).enumerated().forEach {
            self.value[$0.0].value = value[$0.0]
        }
        if self.value.count < value.count {
            self.value.append(contentsOf: value[self.value.count..<value.count].map { ListElement($0) })
        }
    }
    
}

public struct TableView<Root: Modifiable>: View {
    
    let root: Ref<Root>
    @ObservedObject var value: Ref<[[LineAttribute]]>
    @StateObject var viewModel: TableViewModel
    let subView: (TableView, Int, ListElement<[LineAttribute]>) -> TableRowView
    let label: String
    let columns: [BlockAttributeType.TableColumn]
    
    @EnvironmentObject var config: Config
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        self.init(root: root, value: root[path: path], viewModel: TableViewModel(root: root, path: path, columns: columns), label: label, columns: columns) { (me, index, element) in
            return TableRowView(
                root: root,
                path: path[index],
                row: element.value,
                errorsForItem: { me.viewModel.errorsForItem(atRow: index, col: $0) },
                onDelete: { me.viewModel.deleteElement(atIndex: index, withUUID: element.id) }
            )
        }
    }
    
    init(root: Ref<Root>, value: Ref<[[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        let viewModel = TableViewModel(reference: value, columns: columns)
        self.init(root: root, value: value, viewModel: viewModel, label: label, columns: columns) { (me, index, element) in
            return TableRowView(
                value: value[index],
                row: element.value,
                errorsForItem: { me.viewModel.errorsForItem(atRow: index, col: $0) },
                onDelete: { me.viewModel.deleteElement(atIndex: index, withUUID: element.id) }
            )
        }
    }
    
    private init(root: Ref<Root>, value: Ref<[[LineAttribute]]>, viewModel: TableViewModel, label: String, columns: [BlockAttributeType.TableColumn], subView: @escaping (TableView, Int, ListElement<[LineAttribute]>) -> TableRowView) {
        self.root = root
        self.value = value
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
                        ForEach(columns, id: \.name) { column in
                            Text(column.name.pretty)
                                .multilineTextAlignment(.leading)
                                .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        Text("").frame(width: 15)
                    }
                    ForEach(Set(viewModel.errors).sorted(), id: \.self) { error in
                        Text(error).foregroundColor(.red)
                    }
                }, content: {
                    ForEach(Array(viewModel.value.enumerated()), id: \.1.id) { (index, element) in
                        subView(self, index, element)
                    }.onMove(perform: viewModel.moveElements).onDelete(perform: viewModel.deleteElements)
                })
            }.frame(minHeight: CGFloat(28 * viewModel.value.count + 70))
            ScrollView([.vertical], showsIndicators: false) {
                HStack {
                    ForEach(viewModel.newRow.indices) { index in
                        VStack {
                            LineAttributeView(attribute: viewModel.newRow[index], label: "")
                            ForEach(viewModel.errorsForItem(atRow: viewModel.value.count, col: index), id: \.self) { error in
                                Text(error).foregroundColor(.red)
                            }
                        }.frame(minWidth: 0, maxWidth: .infinity)
                    }
                    Button(action: viewModel.addElement, label: {
                        Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                    }).buttonStyle(PlainButtonStyle())
                      .foregroundColor(.blue)
                      .frame(width: 15)
                }
            }.padding(.top, -35).padding(.leading, 15).padding(.trailing, 18).frame(height: 50)
        }.onChange(of: value.value) { _ in
            viewModel.update()
        }
    }
}

struct TableRowView: View {
    
    let subView: (Int) -> LineAttributeView
    let row: [LineAttribute]
    let errorsForItem: (Int) -> [String]
    let onDelete: () -> Void
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, [LineAttribute]>,
        row: [LineAttribute],
        errorsForItem: @escaping (Int) -> [String],
        onDelete: @escaping () -> Void
    ) {
        self.subView = {
            LineAttributeView(root: root, path: path[$0], label: "")
        }
        self.row = row
        self.errorsForItem = errorsForItem
        self.onDelete = onDelete
    }
    
    public init(
        value: Ref<[LineAttribute]>,
        row: [LineAttribute],
        errorsForItem: @escaping (Int) -> [String],
        onDelete: @escaping () -> Void
    ) {
        self.subView = {
            LineAttributeView(attribute: value[$0], label: "")
        }
        self.row = row
        self.errorsForItem = errorsForItem
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack {
            ForEach(Array(row.map { ListElement($0) }.enumerated()), id: \.1.id) { (columnIndex, _) in
                VStack {
                    subView(columnIndex)
                    ForEach(errorsForItem(columnIndex), id: \.self) { error in
                        Text(error).foregroundColor(.red)
                    }
                }
            }
            Image(systemName: "ellipsis").font(.system(size: 16, weight: .regular)).rotationEffect(.degrees(90))
        }.contextMenu {
            Button("Delete", action: onDelete).keyboardShortcut(.delete)
        }
    }
}
