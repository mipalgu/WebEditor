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

struct BlockAttributeView<Path: PathProtocol>: View where Path.Root == Machine, Path.Value == BlockAttribute {
    
    @Binding var machine: Machine
    let path: Path
    let label: String
    
    var body: some View {
        switch machine[keyPath: path.path] {
        case .code(_, let language):
            CodeView(machine: $machine, path: path.codeValue, label: label, language: language)
        case .text:
            TextView(machine: $machine, path: path.textValue, label: label)
        case .table(_, let columns):
            TableView(machine: $machine, path: path.tableValue, label: label, columns: columns)
        default:
            Text("Not Yet Implemented")
        }
    }
}
