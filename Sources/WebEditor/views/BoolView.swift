//
//  LineBoolView.swift
//  TokamakApp
//
//  Created by Morgan McColl on 12/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct BoolView<Path: PathProtocol>: View where Path.Root == Machine, Path.Value == LineAttribute {
    
    @Binding var machine: Machine
    let label: String
    let path: Path
    
    var body: some View {
        Toggle(label, isOn: Binding(get: { machine[keyPath: path.path].boolValue ?? false }, set: {
            do {
                try machine.modify(attribute: path, value: LineAttribute.bool($0))
            } catch let e {
                print("\(e)")
            }
        }))
    }
}

