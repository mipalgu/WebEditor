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

struct TextView<Path: PathProtocol>: View where Path.Root == Machine, Path.Value == BlockAttribute {
    
    @Binding var machine: Machine
    let path: Path
    let label: String
    
    var body: some View {
        VStack {
            Text(label.capitalized)
            TextEditor(text: Binding(get: { machine[keyPath: path.path].textValue ?? "" }, set: {
                do {
                    try machine.modify(attribute: path, value: .text($0))
                } catch let e {
                    print("\(e)")
                }
            }))
        }
    }
}
