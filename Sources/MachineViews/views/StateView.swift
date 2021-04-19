//
//  StateView.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import AttributeViews
import Utilities

struct StateView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Machines.State>
    
    @Binding var expanded: Bool
    @Binding var collapsedActions: [String: Bool]
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, expanded: Binding<Bool> = .constant(false), collapsedActions: Binding<[String: Bool]> = .constant([:])) {
        self._machine = machine
        self.path = path
        self._expanded = expanded
        self._collapsedActions = collapsedActions
    }
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Group {
            if expanded {
                StateExpandedView(root: $machine, path: path, collapsedActions: $collapsedActions) {
                    StateTitleView(machine: $machine, path: path.name, expanded: $expanded)
                }
            } else {
                StateCollapsedView {
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
