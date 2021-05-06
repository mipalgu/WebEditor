//
//  File.swift
//  
//
//  Created by Morgan McColl on 17/4/21.
//

import TokamakShim

import Machines
import AttributeViews
import Attributes
import Transformations
import Utilities

final class StateViewModel: ObservableObject, Identifiable, Hashable {
    
    static func == (lhs: StateViewModel, rhs: StateViewModel) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(stateIndex)
    }
    
    
    private var machine: Binding<Machine>
    
    let path: Attributes.Path<Machine, Machines.State>
    
    var state: Binding<Machines.State>
    
    let stateIndex: Int
    
    weak var notifier: GlobalChangeNotifier?
    
    var actions: [ActionViewModel]
    
    var name: String {
        state.wrappedValue.name
    }
    
    var title: StateTitleViewModel {
        StateTitleViewModel(machine: machine, path: path.name, notifier: notifier)
    }
    
    var transitions: [TransitionViewModel] {
        state.wrappedValue.transitions.indices.map {
            TransitionViewModel(
                machine: machine,
                path: path.transitions[$0],
                transitionBinding: state.transitions[$0],
                stateIndex: stateIndex,
                transitionIndex: $0,
                notifier: notifier
            )
        }
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, state: Binding<Machines.State>, stateIndex: Int, notifier: GlobalChangeNotifier? = nil, actions: [ActionViewModel]) {
        self.machine = machine
        self.path = path
        self.state = state
        self.stateIndex = stateIndex
        self.notifier = notifier
        self.actions = actions
    }
    
    convenience init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, state: Binding<Machines.State>, stateIndex: Int, notifier: GlobalChangeNotifier? = nil) {
        self.init(
            machine: machine,
            path: path,
            state: state,
            stateIndex: stateIndex,
            notifier: notifier,
            actions: state.wrappedValue.actions.indices.map {
                ActionViewModel(machine: machine, path: path.actions[$0], action: state.actions[$0], notifier: notifier, collapsed: false)
            }
        )
    }
    
}
