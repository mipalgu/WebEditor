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
    
    @ObservedObject var machine: Ref<Machine>
    let path: Attributes.Path<Machine, String>?
    let label: String
    let onChange: (String) -> Void
    
    @State var value: String
    
    @EnvironmentObject var config: Config
    
    @State var error: String? = nil
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, String>?, label: String, defaultValue: String = "", onChange: @escaping (String) -> Void = { _ in }) {
        self.machine = machine
        self.path = path
        self.label = label
        self._value = State(initialValue: path.map { machine[path: $0].value } ?? defaultValue)
        self.onChange = onChange
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            TextField(label, text: $value, onCommit: {
                guard let path = self.path else {
                    onChange(value)
                    return
                }
                do {
                    try machine.value.modify(attribute: path, value: value)
                    error = nil
                    onChange(value)
                    return
                } catch let e as MachinesError where e.path.isSame(as: path) {
                    error = e.message
                } catch let e {
                    print("\(e)", stderr)
                }
                value = machine[path: path].value
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
    
    static let machine: Ref<Machine> = Ref(copying: Machine.initialSwiftMachine)
    
    static var previews: some View {
        LineView(
            machine: machine,
            path: Machine.path.states[0].name,
            label: "State 0"
        ).environmentObject(Config())
    }
    
}
