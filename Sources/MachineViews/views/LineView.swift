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

public struct LineView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, String>?
    let label: String
    
    @State var value: String
    
    @EnvironmentObject var config: Config
    
    @State var error: String? = nil
    
    public init(machine: Binding<Machine>, path: Attributes.Path<Machine, String>?, label: String, defaultValue: String = "") {
        self._machine = machine
        self.path = path
        self.label = label
        self._value = State(initialValue: path.map { machine.wrappedValue[keyPath: $0.keyPath] } ?? defaultValue)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            TextField(label, text: $value, onCommit: {
                guard let path = self.path else {
                    return
                }
                do {
                    try machine.modify(attribute: path, value: value)
                    error = nil
                    return
                } catch let e as MachinesError where e.path.isSame(as: path) {
                    error = e.message
                } catch let e {
                    print("\(e)", stderr)
                }
                value = machine[keyPath: path.path]
            })
            .background(config.fieldColor)
            .foregroundColor(config.textColor)
            if let error = self.error {
                Text(error).foregroundColor(.red)
            }
        }
    }
}

struct LineView_Preview: PreviewProvider {
    
    static var machine: Machine = Machine.initialSwiftMachine
    
    static var previews: some View {
        LineView(
            machine: Binding(get: { Self.machine }, set: { Self.machine = $0 }),
            path: Machine.path.states[0].name,
            label: "State 0"
        ).environmentObject(Config())
    }
    
}
