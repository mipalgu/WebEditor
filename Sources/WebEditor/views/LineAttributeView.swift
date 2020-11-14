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

struct LineAttributeView<Path: PathProtocol>: View where Path.Root == Machine, Path.Value == LineAttribute {
    
    @Binding var machine: Machine
    let path: Path
    let label: String
    
    var body: some View {
        switch machine[keyPath: path.path] {
        case .bool:
            BoolView(machine: $machine, label: label, path: path)
        case .integer:
            IntegerView(machine: $machine, label: label, path: path)
        case .float:
            FloatView(machine: $machine, label: label, path: path)
        case .expression(_, let language):
            ExpressionView(machine: $machine, label: label, language: language, path: path)
        case .enumerated(_, let validValues):
            EnumeratedView(machine: $machine, path: path, label: label, validValues: validValues)
        case .line:
            LineView(machine: $machine, path: path, label: label)
        }
    }
}

