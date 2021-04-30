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
    
    @ObservedObject var state: StateViewModel2

    @Binding var collapsedActions: [String: Bool]
    var focused: Bool
    
    init(state: StateViewModel2, collapsedActions: Binding<[String: Bool]> = .constant([:]), focused: Bool = false) {
        self.state = state
        self._collapsedActions = collapsedActions
        self.focused = focused
    }
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Group {
            if state.expanded {
                StateExpandedView(state: state.state, collapsedActions: $collapsedActions, focused: focused) {
                    StateTitleView(name: state.state.name, expanded: state.expandedBinding)
                }
            } else {
                StateCollapsedView(focused: focused) {
                    StateTitleView(name: state.state.name, expanded: state.expandedBinding)
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
            StateView(state: StateViewModel2(state: $machine.states[0]),collapsedActions: $collapsedActions).environmentObject(config)
        }
        
    }
    
    struct Collapsed_Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        @State var expanded: Bool = false
        
        @State var collapsedActions: [String: Bool] = [:]
        
        let config = Config()
        
        var body: some View {
            StateView(state: StateViewModel2(state: $machine.states[0]),collapsedActions: $collapsedActions).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Collapsed_Preview().frame(width: 200, height: 100)
            Expanded_Preview().frame(minHeight: 400)
        }
    }
}
