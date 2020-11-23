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

struct LineAttributeView: View {
    
    @ObservedObject var machine: Ref<Machine>
    @Binding var attribute: LineAttribute
    let path: Attributes.Path<Machine, LineAttribute>?
    let label: String
    
    var body: some View {
        switch attribute.type {
        case .bool:
            BoolView(machine: machine, path: path?.boolValue, label: label)
        case .integer:
            IntegerView(machine: machine, path: path?.integerValue, label: label)
        case .float:
            FloatView(machine: machine, path: path?.floatValue, label: label)
        case .expression(let language):
            ExpressionView(machine: machine, path: path?.expressionValue, label: label, language: language)
        case .enumerated(let validValues):
            EnumeratedView(machine: machine, path: path?.enumeratedValue, label: label, validValues: validValues)
        case .line:
            LineView(machine: machine, path: path?.lineValue, label: label) {
                attribute = .line($0)
            }
        }
    }
}

