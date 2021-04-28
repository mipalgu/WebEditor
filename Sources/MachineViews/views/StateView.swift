//
//  StateView.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

import TokamakShim

import Machines
import Attributes
import AttributeViews
import Utilities

struct StateView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Machines.State>
    
    @Binding var expanded: Bool
    @Binding var collapsedActions: [String: Bool]
    var focused: Bool
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, expanded: Binding<Bool> = .constant(false), collapsedActions: Binding<[String: Bool]> = .constant([:]), focused: Bool = false) {
        self._machine = machine
        self.path = path
        self._expanded = expanded
        self._collapsedActions = collapsedActions
        self.focused = focused
    }
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Group {
            if expanded {
                StateExpandedView(root: $machine, path: path, collapsedActions: $collapsedActions, focused: focused) {
                    StateTitleView(machine: $machine, path: path.name, expanded: $expanded)
                }
            } else {
                StateCollapsedView(focused: focused) {
                    StateTitleView(machine: $machine, path: path.name, expanded: $expanded)
                }
            }
        }
    }
}

struct StateView_Previews: PreviewProvider {
    
    struct Expanded_Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        @State var expanded: Bool = true
        
        @State var collapsedActions: [String: Bool] = [:]
        
        let config = Config()
        
        var body: some View {
            StateView(machine: $machine, path: Machine.path.states[0], expanded: $expanded, collapsedActions: $collapsedActions).environmentObject(config)
        }
        
    }
    
    struct Collapsed_Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        @State var expanded: Bool = false
        
        @State var collapsedActions: [String: Bool] = [:]
        
        let config = Config()
        
        var body: some View {
            StateView(machine: $machine, path: Machine.path.states[0], expanded: $expanded, collapsedActions: $collapsedActions).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Collapsed_Preview().frame(width: 200, height: 100)
            Expanded_Preview().frame(minHeight: 400)
        }
    }
}
