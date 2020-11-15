//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 14/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct StateEditView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Machines.State>
    var state: Machines.State {
        machine[keyPath: path.path]
    }
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        GeometryReader { reader in
            HStack {
                VStack {
                    TextField(String(state.name), text: Binding(get: { String(state.name) }, set: {
                        do {
                            try machine.modify(attribute: path.name, value: StateName($0))
                        } catch let e {
                            print("\(e)")
                        }
                    }))
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .background(config.fieldColor)
                    .foregroundColor(config.textColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                    ForEach(state.actions.sorted(by: { $0.0 < $1.0 }), id: \.0) { (key, value) in
                        CodeView(machine: $machine, path: path.actions[key].wrappedValue, label: key, language: .swift)
                            .frame(height: reader.size.height / CGFloat(state.actions.count))
                    }
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: min(floor(reader.size.width * 9.0 / 10.0), reader.size.width - 150 - 2))
                Divider()
                    .border(Color.black.opacity(0.6), width: 1)
                    .frame(height: reader.size.height)
                AttributeGroupsView(machine: $machine, path: path.attributes, label: "State Attributes")
                    .frame(maxWidth: max(floor(reader.size.width * 1.0 / 10.0), 150 - 2))
            }
        }
    }
}
