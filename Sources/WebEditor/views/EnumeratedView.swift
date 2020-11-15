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

struct EnumeratedView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, String>
    let label: String
    let validValues: Set<String>
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Picker(
            label,
            selection: Binding(get: {machine[keyPath: path.path] }, set: {
                do {
                    try machine.modify(attribute: path, value: $0)
                } catch let e {
                    print("\(e)")
                }
            })
        ) {
            ForEach(validValues.sorted(), id: \.self) {
                Text($0).tag($0)
                    .foregroundColor(config.textColor)
            }
        }
    }
}
