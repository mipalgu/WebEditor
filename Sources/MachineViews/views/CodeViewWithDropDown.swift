//
//  CodeViewWithDropDown.swift
//  
//
//  Created by Morgan McColl on 16/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct CodeViewWithDropDown<Label: View>: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Code>
    let language: Language
    let label: () -> Label
    
    @State var expanded: Bool = true
    
    @EnvironmentObject var config: Config
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Code>, label: String, language: Language) where Label == Text {
        self.init(machine: machine, path: path, language: language) { Text(label.capitalized) }
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Code>, language: Language, label: @escaping () -> Label) {
        self._machine = machine
        self.path = path
        self.language = language
        self.label = label
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                label()
                Button(action: { expanded = !expanded }) {
                    Image(systemName: expanded ? "arrowtriangle.down.fill" : "arrowtriangle.left.fill")
                        .font(.system(size: 8.0, weight: .regular))
                        .frame(width: 12.0, height: 12.0)
                }.buttonStyle(PlainButtonStyle())
                Spacer()
            }
            if expanded {
                TextEditor(text: Binding(get: { machine[keyPath: path.path] }, set: {
                    do {
                        try machine.modify(attribute: path, value: Code($0))
                    } catch let e {
                        print("\(e)")
                    }
                }))
                .font(config.fontBody)
                .foregroundColor(config.textColor)
                .disableAutocorrection(true)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
                .frame(minHeight: 80)
            }
        }
    }
}

