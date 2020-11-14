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

struct ExpressionView<Path: PathProtocol>: View where Path.Root == Machine, Path.Value == LineAttribute {
    
    @Binding var machine: Machine
    let label: String
    let language: Language
    let path: Path
    
    var body: some View {
        TextField(label, text: Binding(get: { String(machine[keyPath: path.path].expressionValue ?? Expression()) }, set: {
            do {
                try machine.modify(attribute: path, value: LineAttribute.expression(Expression($0), language: language))
            } catch let e {
                print("\(e)")
            }
        }))
    }
}
