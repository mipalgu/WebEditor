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

struct CodeView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Code>
    let label: String
    let language: Language
    
    var body: some View {
        VStack {
            Text(label.capitalized)
            TextEditor(text: Binding(get: { machine[keyPath: path.path] }, set: {
                do {
                    try machine.modify(attribute: path, value: Code($0))
                } catch let e {
                    print("\(e)")
                }
            }))
        }
    }
}
