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

struct TextView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, String>
    let label: String
    
    var body: some View {
        VStack {
            Text(label.capitalized)
            TextEditor(text: Binding(get: { machine[keyPath: path.path] }, set: {
                do {
                    try machine.modify(attribute: path, value: $0)
                } catch let e {
                    print("\(e)")
                }
            }))
        }
    }
}
