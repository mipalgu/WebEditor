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
    
    private var machineBinding: Binding<Machine>
    
    let path: Attributes.Path<Machine, Action>
    
    weak var notifier: GlobalChangeNotifier?
    
    @Published var collapsed: Bool
    
    var machine: Machine {
        get {
            machineBinding.wrappedValue
        } set {
            machineBinding.wrappedValue = newValue
            self.objectWillChange.send()
        }
    }
    
    private var action: Action {
        get {
            path.isNil(machine) ? Action(name: "", implementation: "", language: .swift) : machine[keyPath: path.keyPath]
        } set {
            defer { objectWillChange.send() }
            if path.isNil(machine) {
                return
            }
            machine[keyPath: path.path] = newValue
        }
    }
    
    var name: String {
        action.name
    }
    
    var language: Language {
        action.language
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Action>, notifier: GlobalChangeNotifier? = nil, collapsed: Bool = false) {
        self.machineBinding = machine
        self.path = path
        self.notifier = notifier
        self.collapsed = collapsed
    }
    
}
