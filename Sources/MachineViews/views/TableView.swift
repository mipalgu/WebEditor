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
    let path: Attributes.Path<Machine, [[LineAttribute]]>
    let label: String
    let columns: [BlockAttributeType.TableColumn]
    
    @EnvironmentObject var config: Config
    
    @State var selection: Set<Int> = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label.capitalized)
                .font(.headline)
                .foregroundColor(config.textColor)
            List(selection: $selection) {
                HStack {
                    ForEach(Array(columns.indices), id: \.self) { index in
                        Text(columns[index].name.pretty)
                    }
                }
                ForEach(Array(machine[keyPath: path.path].indices), id: \.self) { rowIndex in
                    TableRowView(machine: $machine, path: path[rowIndex])
                }
            }.frame(minHeight: 100)
        }
    }
}

struct TableRowView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, [LineAttribute]>
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        HStack {
            ForEach(Array(machine[keyPath: path.path].indices), id: \.self) { columnIndex in
                LineAttributeView(machine: $machine, path: path[columnIndex], label: "")
            }
        }
    }
}
