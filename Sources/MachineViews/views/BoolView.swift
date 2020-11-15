//
//  LineBoolView.swift
//  TokamakApp
//
//  Created by Morgan McColl on 12/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct BoolView: View {
    
    @Binding var machine: Machine
    let label: String
    let path: Attributes.Path<Machine, Bool>
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Toggle(label, isOn: Binding(get: { machine[keyPath: path.path] }, set: {
            do {
                try machine.modify(attribute: path, value: $0)
            } catch let e {
                print("\(e)")
            }
        }))
            .font(.body)
        .foregroundColor(config.textColor)
    }
}

