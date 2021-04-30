//
//  File.swift
//  
//
//  Created by Morgan McColl on 17/4/21.
//

import TokamakShim

import Machines
import Attributes
import Transformations
import Utilities

final class StateViewModel: ObservableObject {
    
    private var machine: Binding<Machine>
    
    let path: Attributes.Path<Machine, Machines.State>
    
    var state: Binding<Machines.State>
    
    weak var notifier: GlobalChangeNotifier?
    
    var actions: [ActionViewModel]
    
    var title: StateTitleViewModel {
        StateTitleViewModel(machine: machine, path: path.name, notifier: notifier)
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, state: Binding<Machines.State>, notifier: GlobalChangeNotifier? = nil, actions: [ActionViewModel]) {
        self.machine = machine
        self.path = path
        self.state = state
        self.notifier = notifier
        self.actions = actions
    }
    
    convenience init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, state: Binding<Machines.State>, notifier: GlobalChangeNotifier? = nil) {
        self.init(
            machine: machine,
            path: path,
            state: state,
            notifier: notifier,
            actions: state.wrappedValue.actions.indices.map {
                ActionViewModel(machine: machine, path: path.actions[$0], action: state.actions[$0], notifier: notifier, collapsed: false)
            }
        )
    }
    
}
