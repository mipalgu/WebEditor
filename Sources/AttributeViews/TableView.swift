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

import Machines
import Attributes
import Utilities

public struct TableView: View {
    
    @Binding var value: [[LineAttribute]]
    let label: String
    let columns: [BlockAttributeType.TableColumn]
    let onCommit: ([[LineAttribute]]) -> Void
    
    @EnvironmentObject var config: Config
    
    @State var selection: Set<Int> = []
    
    public init(value: Binding<[[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn], onCommit: @escaping ([[LineAttribute]]) -> Void = { _ in }) {
        self._value = value
        self.label = label
        self.columns = columns
        self.onCommit = onCommit
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
                    TableRowView(row: $value[rowIndex]) { _ in
                        self.onCommit(value)
                    }
                }
            }.frame(minHeight: 100)
        }
    }
}

struct TableRowView: View {
    @Binding var row: [LineAttribute]
    let onCommit: ([LineAttribute]) -> Void
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        HStack {
            ForEach(Array(row.indices), id: \.self) { columnIndex in
                LineAttributeView(attribute: $row[columnIndex], label: "") { _ in
                    self.onCommit(row)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
    }
}
