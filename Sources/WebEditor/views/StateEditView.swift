//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 14/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct StateEditView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Machines.State>
    var state: Machines.State {
        machine[keyPath: path.path]
    }
    
    var body: some View {
        VStack {
            TextField(String(state.name), text: Binding(get: { String(state.name) }, set: {
                do {
                    try machine.modify(attribute: path.name, value: StateName($0))
                } catch let e {
                    print("\(e)")
                }
            }))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            ForEach(state.actions.sorted(by: { $0.0 < $1.0 }), id: \.0) { (key, value) in
                
            }
        }
    }
}
