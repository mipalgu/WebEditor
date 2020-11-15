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
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        VStack {
            Text(label.capitalized)
                .font(.headline)
                .foregroundColor(config.textColor)
            TextEditor(text: Binding(get: { machine[keyPath: path.path] }, set: {
                do {
                    try machine.modify(attribute: path, value: $0)
                } catch let e {
                    print("\(e)")
                }
            }))
            .font(.body)
            .foregroundColor(config.textColor)
            .disableAutocorrection(false)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
    }
}
