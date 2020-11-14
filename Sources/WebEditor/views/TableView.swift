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

struct TableView<Path: PathProtocol>: View where Path.Root == Machine, Path.Value == BlockAttribute {
    
    @Binding var machine: Machine
    let path: Path
    let label: String
    let columns: [BlockAttributeType.TableColumn]
    
    var body: some View {
        VStack {
            Text(label.capitalized)
            List(Array(machine[keyPath: path.path].tableValue.indices), id: \.self) { rowIndex in
                ForEach(Array(machine[keyPath: path.path].tableValue[rowIndex].indices), id: \.self) { columnIndex in
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
