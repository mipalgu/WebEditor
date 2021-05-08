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

final class StateViewModel: ObservableObject, Identifiable, Hashable, GlobalChangeNotifierDelegator {
    
    static func == (lhs: StateViewModel, rhs: StateViewModel) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(stateIndex)
    }
    
    var cache: ViewCache
    
    private var machine: Binding<Machine>
    
    let path: Attributes.Path<Machine, Machines.State>
    
    var state: Binding<Machines.State>
    
    let stateIndex: Int
    
    weak var notifier: GlobalChangeNotifier?
    
    var actions: [ActionViewModel]
    
    var name: StateName {
        state.wrappedValue.name
    }
    
    var title: StateTitleViewModel {
        StateTitleViewModel(machine: machine, path: path.name, cache: cache, notifier: notifier)
    }
    
    var transitions: [TransitionViewModel] {
        self.cache.transitions(source: name)
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, state: Binding<Machines.State>, stateIndex: Int,  cache: ViewCache, notifier: GlobalChangeNotifier? = nil, actions: [ActionViewModel]) {
        self.machine = machine
        self.path = path
        self.state = state
        self.stateIndex = stateIndex
        self.notifier = notifier
        self.actions = actions
        self.cache = cache
        self.actions.forEach {
            $0.notifier = self
        }
    }
    
    convenience init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, state: Binding<Machines.State>, stateIndex: Int,  cache: ViewCache, notifier: GlobalChangeNotifier? = nil) {
        self.init(
            machine: machine,
            path: path,
            state: state,
            stateIndex: stateIndex,
            cache: cache,
            notifier: notifier,
            actions: state.wrappedValue.actions.indices.map {
                ActionViewModel(machine: machine, path: path.actions[$0], notifier: notifier, collapsed: false)
            }
        )
    }
    
}
