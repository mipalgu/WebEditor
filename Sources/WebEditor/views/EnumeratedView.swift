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

struct EnumeratedView<Path: PathProtocol>: View where Path.Root == Machine, Path.Value == LineAttribute {
    
    @Binding var machine: Machine
    let path: Path
    let label: String
    let validValues: Set<String>
    
    var body: some View {
        Picker(
            label,
            selection: Binding(
                get: {machine[keyPath: path.path].enumeratedValue ?? validValues.first ?? ""},
                set: {
                    do {
                        try machine.modify(attribute: path, value: LineAttribute.enumerated($0, validValues: validValues))
                    } catch let e {
                        print("\(e)")
                    }
                }
            )
        ) {
            ForEach(validValues.sorted(), id: \.self) {
                Text($0).tag($0)
            }
        }
    }
}
