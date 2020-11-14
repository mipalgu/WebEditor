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

struct IntegerView<Path: PathProtocol>: View where Path.Root == Machine, Path.Value == LineAttribute {

    @Binding var machine: Machine
    let label: String
    let path: Path
    
    var body: some View {
        TextField(label, text: Binding(get: { String(machine[keyPath: path.path].integerValue ?? 0) }, set: {
            guard let value = Int($0) else {
                return
            }
            do {
                try machine.modify(attribute: path, value: LineAttribute.integer(value))
            } catch let e {
                print("\(e)")
            }
        }))
    }
}
