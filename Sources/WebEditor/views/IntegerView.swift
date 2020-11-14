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

struct IntegerView: View {

    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Int>
    let label: String
    
    var body: some View {
        TextField(label, text: Binding(get: { String(machine[keyPath: path.path]) }, set: {
            guard let value = Int($0) else {
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
