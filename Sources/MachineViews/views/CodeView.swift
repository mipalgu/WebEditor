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

struct CodeView<Label: View>: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Code>?
    let language: Language
    let label: () -> Label
    
    @State var value: String
    
    @EnvironmentObject var config: Config
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Code>?, label: String, language: Language, defaultValue: Code = "") where Label == Text {
        self.init(machine: machine, path: path, language: language, defaultValue: defaultValue) { Text(label.capitalized) }
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Code>?, language: Language, defaultValue: Code = "", label: @escaping () -> Label) {
        self._machine = machine
        self.path = path
        self.language = language
        self.label = label
        self._value = State(initialValue: path.map { String(machine.wrappedValue[keyPath: $0.keyPath]) } ?? String(defaultValue))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            label()
            TextEditor(text: $value)
                .font(config.fontBody)
                .foregroundColor(config.textColor)
                .disableAutocorrection(true)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
                .frame(minHeight: 80)
                .onChange(of: value) {
                    guard let path = self.path else {
                        return
                    }
                    do {
                        try machine.modify(attribute: path, value: Code($0))
                        return
                    } catch let e {
                        print("\(e)")
                    }
                    self.value = String(machine[keyPath: path.keyPath])
                }
        }
    }
}
