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

struct BoolView: View {
    
    @ObservedObject var machine: Ref<Machine>
    let path: Attributes.Path<Machine, Bool>?
    let label: String
    
    @State var value: Bool
    
    init(machine: Ref<Machine>, path: Attributes.Path<Machine, Bool>?, label: String, defaultValue: Bool = false) {
        self.machine = machine
        self.path = path
        self.label = label
        self._value = State(initialValue: path.map { machine[path: $0].value } ?? defaultValue)
    }
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Toggle(label, isOn: $value)
            .font(.body)
            .foregroundColor(config.textColor)
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
                value = machine[path: path].value
            }
    }
}

