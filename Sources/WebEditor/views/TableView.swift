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
    
    var body: some View {
        VStack {
            Text(label.capitalized)
            List(Array(machine[keyPath: path.path].indices), id: \.self) { rowIndex in
                ForEach(Array(machine[keyPath: path.path][rowIndex].indices), id: \.self) { columnIndex in
                    LineAttributeView(
                        machine: $machine,
                        path: Attributes.Path(
                            path: path.path.appending(path: \.tableValue[rowIndex][columnIndex]),
                            ancestors: []
                        ),
                        label: label
                    )
                }
            }
        }
    }
}
