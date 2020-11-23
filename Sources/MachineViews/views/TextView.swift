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
    
    @ObservedObject var machine: Ref<Machine>
    let path: Attributes.Path<Machine, String>?
    let label: String
    
    @State var value: String
    
    @EnvironmentObject var config: Config
    
    init(machine: Ref<Machine>, path: Attributes.Path<Machine, String>?, label: String, defaultValue: String = "") {
        self.machine = machine
        self.path = path
        self.label = label
        self._value = State(initialValue: path.map { machine[path: $0].value } ?? defaultValue)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label.capitalized)
                .font(.headline)
                .foregroundColor(config.textColor)
            TextEditor(text: $value)
                .font(.body)
                .foregroundColor(config.textColor)
                .disableAutocorrection(false)
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
                        try machine.value.modify(attribute: path, value: $0)
                        return
                    } catch let e {
                        print("\(e)")
                    }
                    self.value = machine[path: path].value
                }
        }
    }
}
