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
    
    init<Root>(root: Ref<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, columns: [BlockAttributeType.TableColumn]) where Root : Modifiable {
        self._addElement = { me in
            let result: ()? = try? root.value.addItem(me.newRow.map(\.value), to: path)
            me.value = root[path: path].value.map { ListElement($0) }
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
            me.value = root[path: path].value.map { ListElement($0) }
            me.errors = root.value.errorBag.errors(includingDescendantsForPath: path).map(\.message)
            if nil != result {
                root.objectWillChange.send()
            }
        }
        self._moveElements = { (me, source, destination) in
            let result: ()? = try? root.value.moveItems(table: path, from: source, to: destination)
            me.value = root[path: path].value.map { ListElement($0) }
            me.errors = root.value.errorBag.errors(includingDescendantsForPath: path).map(\.message)
            if nil != result {
                root.objectWillChange.send()
            }
        }
        self._errorsForItem = { (me, row, col) in
            return root.value.errorBag.errors(forPath: AnyPath(path[row][col])).map(\.message)
        }
        self.newRow = columns.map { Ref(copying: $0.type.defaultValue) }
        self._rootValue = Reference(wrappedValue: root[path: path].value.map { ListElement($0) })
        self.errors = root.value.errorBag.errors(includingDescendantsForPath: path).map(\.message)
        newRow.forEach(self.listen)
    }
    
    init(reference ref: Ref<[[LineAttribute]]>, columns: [BlockAttributeType.TableColumn]) {
        self._addElement = { me in
            ref.value.append(me.newRow.map(\.value))
            me.newRow.forEach {
                $0.value = $0.type.defaultValue.value
            }
            me.value = ref.value.map { ListElement($0) }
        }
        self._deleteElements = { (me, offsets) in
            ref.value.remove(atOffsets: offsets)
            me.value = ref.value.map { ListElement($0) }
        }
        self._moveElements = { (me, source, destination) in
            ref.value.move(fromOffsets: source, toOffset: destination)
            me.value = ref.value.map { ListElement($0) }
        }
        self._errorsForItem = { (_, _, _) in [] }
        self.newRow = columns.map { Ref(copying: $0.type.defaultValue) }
        self._rootValue = Reference(wrappedValue: ref.value.map { ListElement($0) })
        self.errors = []
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
    
    func deleteElement(atIndex index: Int, withUUID uuid: UUID) {
        let offsets: IndexSet = self.selection.contains(uuid)
            ? IndexSet(self.value.enumerated().lazy.filter { self.selection.contains($1.id) }.map { $0.0 })
            : [index]
        self.deleteElements(offsets: offsets)
    }
    
    func errorsForItem(atRow row: Int, col: Int) -> [String] {
        self._errorsForItem(self, row, col)
    }
    
}

public struct TableView<Root: Modifiable>: View {
    
    let root: Ref<Root>
    @ObservedObject var value: Ref<[[LineAttribute]]>
    @StateObject var viewModel: TableViewModel
    let subView: (TableView, ListElement<[LineAttribute]>) -> AnyView
    let label: String
    let columns: [BlockAttributeType.TableColumn]
    
    @EnvironmentObject var config: Config
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        self.init(root: root, value: root[path: path], viewModel: TableViewModel(root: root, path: path, columns: columns), label: label, columns: columns) { (me, element) in
            guard let index = me.viewModel.value.firstIndex(where: { $0.id == element.id }) else {
                fatalError("Cannot find element \(element).")
            }
            return AnyView(HStack {
                ForEach(Array(element.value.map { ListElement($0) }.enumerated()), id: \.1.id) { (columnIndex, _) in
                    VStack {
                        LineAttributeView(root: root, path: path[index][columnIndex], label: "")
                        ForEach(me.viewModel.errorsForItem(atRow: index, col: columnIndex), id: \.self) { error in
                            Text(error).foregroundColor(.red)
                        }
                    }
                }
                Image(systemName: "ellipsis").font(.system(size: 16, weight: .regular)).rotationEffect(.degrees(90))
            }.contextMenu {
                Button("Delete", action: { me.viewModel.deleteElement(atIndex: index, withUUID: element.id) }).keyboardShortcut(.delete)
            })
//            return TableRowView(
//                root: root,
//                path: path[index],
//                row: me.$viewModel.value[index].value,
//                errorsForItem: { me.viewModel.errorsForItem(atRow: index, col: $0) }
//            ) {
//                me.viewModel.deleteElement(atIndex: index, withUUID: me.viewModel.value[index].id)
//            }
        }
    }
    
    init(root: Ref<Root>, value: Ref<[[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        let viewModel = TableViewModel(reference: value, columns: columns)
        self.init(root: root, value: value, viewModel: viewModel, label: label, columns: columns) { (me, element) in
            guard let index = me.viewModel.value.firstIndex(where: { $0.id == element.id }) else {
                fatalError("Cannot find element \(element).")
            }
            return AnyView(HStack {
                ForEach(Array(element.value.map { ListElement($0) }.enumerated()), id: \.1.id) { (columnIndex, _) in
                    VStack {
                        LineAttributeView(attribute: value[index][columnIndex], label: "")
                        ForEach(me.viewModel.errorsForItem(atRow: index, col: columnIndex), id: \.self) { error in
                            Text(error).foregroundColor(.red)
                        }
                    }
                }
                Image(systemName: "ellipsis").font(.system(size: 16, weight: .regular)).rotationEffect(.degrees(90))
            })
        }
    }
    
    private init(root: Ref<Root>, value: Ref<[[LineAttribute]]>, viewModel: TableViewModel, label: String, columns: [BlockAttributeType.TableColumn], subView: @escaping (TableView, ListElement<[LineAttribute]>) -> AnyView) {
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
                    ForEach(Array(viewModel.value.enumerated()), id: \.1.id) { (index, _) -> AnyView in
                        subView(self, viewModel.value[index])
                    }.onMove(perform: viewModel.moveElements).onDelete(perform: viewModel.deleteElements)
                })
            }.padding(.bottom, -15).frame(minHeight: CGFloat(30 * viewModel.value.count + 35))
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
            }.padding(.leading, 15).padding(.trailing, 18).frame(height: 50)
        }.onChange(of: value.value) {
            viewModel.value = $0.map { ListElement($0) }
        }
    }
}

struct TableRowView: View {
    
    let subView: (Int) -> LineAttributeView
    @Binding var row: [LineAttribute]
    let errorsForItem: (Int) -> [String]
    let onDelete: () -> Void
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, [LineAttribute]>,
        row: Binding<[LineAttribute]>,
        errorsForItem: @escaping (Int) -> [String],
        onDelete: @escaping () -> Void
    ) {
        self.subView = {
            LineAttributeView(root: root, path: path[$0], label: "")
        }
        self._row = row
        self.errorsForItem = errorsForItem
        self.onDelete = onDelete
    }
    
    public init(
        value: Ref<[LineAttribute]>,
        row: Binding<[LineAttribute]>,
        errorsForItem: @escaping (Int) -> [String],
        onDelete: @escaping () -> Void
    ) {
        self.subView = {
            LineAttributeView(attribute: value[$0], label: "")
        }
        self._row = row
        self.errorsForItem = errorsForItem
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack {
            Text("hello")
//            ForEach(Array(row.indices), id: \.self) { columnIndex in
//                VStack {
//                    subView(columnIndex)
//                    ForEach(errorsForItem(columnIndex), id: \.self) { error in
//                        Text(error).foregroundColor(.red)
//                    }
//                }
//            }
            Image(systemName: "ellipsis").font(.system(size: 16, weight: .regular)).rotationEffect(.degrees(90))
        }/*.contextMenu {
            Button("Delete", action: onDelete).keyboardShortcut(.delete)
        }*/
    }
}
