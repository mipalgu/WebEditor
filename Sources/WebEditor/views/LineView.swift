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

struct LineView<Path: PathProtocol>: View where Path.Root == Machine, Path.Value == LineAttribute {
    
    @Binding var machine: Machine
    let path: Path
    let label: String
    
    var body: some View {
        TextField(label, text: Binding(get: { machine[keyPath: path.path].lineValue ?? "" }, set: {
            do {
                try machine.modify(attribute: path, value: LineAttribute.line($0))
            } catch let e {
                print("\(e)")
            }
        }))
    }
}
