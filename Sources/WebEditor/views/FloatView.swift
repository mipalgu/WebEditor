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

struct FloatView: View {

    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Double>
    let label: String
    
    
    var body: some View {
        TextField(label, text: Binding(get: { String(machine[keyPath: path.path]) }, set: {
            guard let value = Double($0) else {
                return
            }
            do {
                try machine.modify(attribute: path, value: value)
            } catch let e {
                print("\(e)")
            }
        }))
    }
}
