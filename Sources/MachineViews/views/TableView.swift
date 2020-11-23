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

struct TableView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, [[LineAttribute]]>?
    let label: String
    let columns: [BlockAttributeType.TableColumn]
    
    @State var value: [[LineAttribute]]
    
    @EnvironmentObject var config: Config
    
    @State var selection: Set<Int> = []
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, [[LineAttribute]]>?, label: String, columns: [BlockAttributeType.TableColumn], defaultValue: [[LineAttribute]] = []) {
        self._machine = machine
        self.path = path
        self.label = label
        self.columns = columns
        self._value = State(initialValue: path.map { machine.wrappedValue[keyPath: $0.keyPath] } ?? defaultValue)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label.capitalized)
                .font(.headline)
                .foregroundColor(config.textColor)
            List(selection: $selection) {
                HStack {
                    Spacer()
                    ForEach(Array(columns.indices), id: \.self) { index in
                        Text(columns[index].name.pretty)
                        Spacer()
                    }
                }
                ForEach(Array(value.indices), id: \.self) { rowIndex in
                    TableRowView(machine: $machine, path: path?[rowIndex], row: $value[rowIndex])
                }
            }.frame(minHeight: 100)
        }
    }
}

struct TableRowView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, [LineAttribute]>?
    @Binding var row: [LineAttribute]
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        HStack {
            Spacer()
            ForEach(Array(row.indices), id: \.self) { columnIndex in
                LineAttributeView(machine: $machine, attribute: $row[columnIndex], path: path?[columnIndex], label: "")
                Spacer()
            }
        }
    }
}
