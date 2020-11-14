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

struct FloatView<Path: PathProtocol>: View where Path.Root == Machine, Path.Value == LineAttribute {

    @Binding var machine: Machine
    let label: String
    let path: Path
    
    var body: some View {
        TextField(label, text: Binding(get: { String(machine[keyPath: path.path].floatValue ?? 0.0) }, set: {
            guard let value = Double($0) else {
                return
            }
            do {
                try machine.modify(attribute: path, value: LineAttribute.float(value))
            } catch let e {
                print("\(e)")
            }
        }))
    }
}
