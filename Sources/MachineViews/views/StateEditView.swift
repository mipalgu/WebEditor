//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 14/11/20.
//

import TokamakShim

import Machines
import Attributes
import Utilities
import AttributeViews

struct StateEditView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Machines.State>
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    LineView<Config>(root: $machine, path: path.name, label: "State Name")
                        .multilineTextAlignment(.center)
                        .font(config.fontTitle2)
                        .background(config.fieldColor)
                        .foregroundColor(config.textColor)
                    ForEach(Array(machine[keyPath: path.keyPath].actions.enumerated()), id: \.1) { (index, action) in
                        CodeView<Config, Text>(root: $machine, path: path.actions[index].implementation, language: .swift) {
                            let view = Text(action.name + ":").font(config.fontHeading).underline().foregroundColor(config.stateTextColour)
                            if action.implementation.isEmpty {
                                return view.italic()
                            } else {
                                return view
                            }
                        }
                        .frame(minHeight: max(geometry.size.height / 3 - 25, 50))
                    }
                }.padding(10)
            }.frame(height: geometry.size.height)
        }
    }
}

struct StateEditView_Previews: PreviewProvider {
    
    struct Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        let path = Machine.path.states[0]
        
        let config = Config()
        
        var body: some View {
            StateEditView(machine: $machine, path: path).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Preview()
        }
    }
}
