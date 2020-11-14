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

struct CodeView<Path: PathProtocol>: View where Path.Root == Machine, Path.Value == BlockAttribute {
    
    @Binding var machine: Machine
    let path: Path
    let label: String
    let language: Language
    
    var body: some View {
        VStack {
            Text(label.capitalized)
            TextEditor(text: Binding(get: { machine[keyPath: path.path].codeValue ?? "" }, set: {
                do {
                    try machine.modify(attribute: path, value: .code($0, language: language))
                } catch let e {
                    print("\(e)")
                }
            }))
        }
    }
}
