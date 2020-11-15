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

struct LineView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, String>
    let label: String
    
    @EnvironmentObject var config: Config
    
    @SwiftUI.State var text: String
    
    @SwiftUI.State var error: String? = nil
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, String>, label: String) {
        self._machine = machine
        self.path = path
        self.label = label
        self._text = SwiftUI.State(initialValue: machine.wrappedValue[keyPath: path.path])
    }
    
    var body: some View {
        VStack {
            TextField(label, text: $text, onCommit: {
                do {
                    try machine.modify(attribute: path, value: self.text)
                    text = machine[keyPath: path.path]
                    error = nil
                } catch let e as MachinesError {
                    error = e.message
                } catch let e {
                    error = "\(e)"
                }
            })
            .font(.body)
            .background(config.fieldColor)
            .foregroundColor(config.textColor)
            if let error = self.error {
                Text(error).foregroundColor(.red)
            }
        }
    }
}
