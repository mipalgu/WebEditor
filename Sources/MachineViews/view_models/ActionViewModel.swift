//
//  ActionViewModel.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import Foundation
import TokamakShim
import AttributeViews
import Attributes
import Machines

final class ActionViewModel: ObservableObject, GlobalChangeNotifierDelegator, Identifiable {
    
    let machineBinding: Binding<Machine>
    
    let path: Attributes.Path<Machine, Action>
    
    weak var notifier: GlobalChangeNotifier?
    
    @Published var expanded: Bool
    
    var machine: Machine {
        get {
            machineBinding.wrappedValue
        } set {
            machineBinding.wrappedValue = newValue
            self.objectWillChange.send()
        }
    }
    
    private var action: Action {
        path.isNil(machine) ? Action(name: "", implementation: "", language: .swift) : machine[keyPath: path.keyPath]
    }
    
    var name: String {
        action.name
    }
    
    var language: Language {
        action.language
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Action>, notifier: GlobalChangeNotifier? = nil, expanded: Bool = true) {
        self.machineBinding = machine
        self.path = path
        self.notifier = notifier
        self.expanded = expanded
    }
    
}
