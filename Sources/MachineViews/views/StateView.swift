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
    
    var state: StateViewModel
    
    @ObservedObject var tracker: StateTracker
    
    var coordinateSpace: String
    
    var frame: CGSize

    var focused: Bool
    
    init(state: StateViewModel, tracker: StateTracker, coordinateSpace: String, frame: CGSize, focused: Bool = false) {
        self.state = state
        self.tracker = tracker
        self.coordinateSpace = coordinateSpace
        self.frame = frame
        self.focused = focused
    }
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Group {
            if tracker.expanded {
                StateExpandedView(actions: state.actions, focused: focused) {
                    StateTitleView(viewModel: state.title, expanded: $tracker.expanded)
                }
            } else {
                StateCollapsedView(focused: focused) {
                    StateTitleView(viewModel: state.title, expanded: $tracker.expanded)
                }
            }
        }
//        .position(tracker.location)
//        .coordinateSpace(name: coordinateSpace)
//        .position(tracker.location)
        .frame(
            width: tracker.width,
            height: tracker.height
        )
    }
}

struct StateView_Previews: PreviewProvider {
    
    struct Expanded_Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        
        @State var expanded: Bool = true
        
        let config = Config()
        
        var body: some View {
            StateView(
                state: StateViewModel(
                    machine: $machine,
                    path: machine.path.states[0],
                    state: $machine.states[0],
                    stateIndex: 0,
                    cache: ViewCache(machine: $machine),
                    notifier: nil
                ),
                tracker: StateTracker(expanded: expanded),
                coordinateSpace: "MAIN_VIEW",
                frame: CGSize(width: 1000.0, height: 1000.0)
            ).environmentObject(config)
        }
        
    }
    
    struct Collapsed_Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        @State var expanded: Bool = false
        
        @State var collapsedActions: [String: Bool] = [:]
        
        let config = Config()
        
        var body: some View {
            StateView(
                state: StateViewModel(
                    machine: $machine,
                    path: machine.path.states[0],
                    state: $machine.states[0],
                    stateIndex: 0,
                    cache: ViewCache(machine: $machine),
                    notifier: nil
                ),
                tracker: StateTracker(expanded: expanded),
                coordinateSpace: "MAIN_VIEW",
                frame: CGSize(width: 1000.0, height: 1000.0)
            ).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Collapsed_Preview().frame(width: 200, height: 100)
            Expanded_Preview().frame(minHeight: 400)
        }
    }
}
