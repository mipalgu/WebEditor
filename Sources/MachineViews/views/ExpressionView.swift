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

struct ExpressionView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Expression>
    let label: String
    let language: Language
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        TextField(label, text: Binding(get: { String(machine[keyPath: path.path]) }, set: {
            do {
                try machine.modify(attribute: path, value: Expression($0))
            } catch let e {
                print("\(e)")
            }
        }))
        .font(.body)
        .background(config.fieldColor)
        .foregroundColor(config.textColor)
    }
}
