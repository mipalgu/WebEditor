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

public struct TableView<Root: Modifiable>: View {
    
    @ObservedObject var root: Ref<Root>
    let path: Attributes.Path<Root, [[LineAttribute]]>?
    let label: String
    let columns: [BlockAttributeType.TableColumn]
    
    @State var value: [[LineAttribute]]
    
    @EnvironmentObject var config: Config
    
    @State var selection: Set<Int> = []
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, [[LineAttribute]]>?, label: String, columns: [BlockAttributeType.TableColumn], defaultValue: [[LineAttribute]] = []) {
        self.root = root
        self.path = path
        self.label = label
        self.columns = columns
        self._value = State(initialValue: path.map { root[path: $0].value } ?? defaultValue)
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
                ForEach(Array(value.indices), id: \.self) { rowIndex in
                    TableRowView(root: root, path: path?[rowIndex], row: $value[rowIndex])
                }
            }.frame(minHeight: 100)
        }
    }
}

struct TableRowView<Root: Modifiable>: View {
    
    @ObservedObject var root: Ref<Root>
    let path: Attributes.Path<Root, [LineAttribute]>?
    @Binding var row: [LineAttribute]
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        HStack {
            ForEach(Array(row.indices), id: \.self) { columnIndex in
                LineAttributeView(root: root, attribute: $row[columnIndex], path: path?[columnIndex], label: "")
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
    }
}
