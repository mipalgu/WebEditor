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
    
    @ObservedObject var state: StateViewModel

    var focused: Bool
    
    init(state: StateViewModel, focused: Bool = false) {
        self.state = state
        self.focused = focused
    }
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Group {
            if state.expanded {
                StateExpandedView(actions: state.actions, focused: focused) {
                    StateTitleView(viewModel: state.title, expanded: state.expandedBinding)
                }
            } else {
                StateCollapsedView(focused: focused) {
                    StateTitleView(viewModel: state.title, expanded: state.expandedBinding)
                }
            }
        }
    }
}

struct StateView_Previews: PreviewProvider {
    
    struct Expanded_Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        @State var expanded: Bool = true
        
        let config = Config()
        
        var body: some View {
            StateView(state: StateViewModel(machine: $machine, path: machine.path.states[0], state: $machine.states[0], notifier: nil)).environmentObject(config)
        }
        
    }
    
    struct Collapsed_Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        @State var expanded: Bool = false
        
        @State var collapsedActions: [String: Bool] = [:]
        
        let config = Config()
        
        var body: some View {
            StateView(state: StateViewModel(machine: $machine, path: machine.path.states[0], state: $machine.states[0], notifier: nil)).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Collapsed_Preview().frame(width: 200, height: 100)
            Expanded_Preview().frame(minHeight: 400)
        }
    }
}
