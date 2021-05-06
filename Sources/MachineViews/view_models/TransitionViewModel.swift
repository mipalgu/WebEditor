//
//  File.swift
//  
//
//  Created by Morgan McColl on 18/4/21.
//

import Foundation
import TokamakShim
import Transformations
import Utilities
import GUUI
import Machines
import Attributes

final class TransitionViewModel: ObservableObject, Identifiable {
    
    private var machine: Binding<Machine>
    
    let path: Attributes.Path<Machine, Transition>
    
    var transitionBinding: Binding<Transition>
    
    let stateIndex: Int
    
    let transitionIndex: Int
    
    weak var notifier: GlobalChangeNotifier?
    
    var condition: Binding<String> {
        Binding(
            get: {
                self.transitionBinding.wrappedValue.condition ?? ""
            },
            set: {
                let result = self.machine.wrappedValue.modify(attribute: self.path.condition, value: $0)
                guard let notifier = self.notifier, let hasTrigger = try? result.get(), hasTrigger == true else {
                    self.objectWillChange.send()
                    return
                }
                notifier.send()
            }
        )
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Transition>, transitionBinding: Binding<Transition>, stateIndex: Int, transitionIndex: Int, notifier: GlobalChangeNotifier? = nil) {
        self.machine = machine
        self.path = path
        self.transitionBinding = transitionBinding
        self.stateIndex = stateIndex
        self.transitionIndex = transitionIndex
        self.notifier = notifier
    }
    
}

extension TransitionViewModel: Hashable {
    static func == (lhs: TransitionViewModel, rhs: TransitionViewModel) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(stateIndex)
        hasher.combine(transitionIndex)
    }
    
}
