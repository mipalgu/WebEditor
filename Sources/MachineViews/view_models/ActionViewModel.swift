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

final class ActionViewModel: ObservableObject, Hashable, GlobalChangeNotifierDelegator {
    
    static func == (lhs: ActionViewModel, rhs: ActionViewModel) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
    
    private var machineBinding: Binding<Machine>
    
    var machine: Machine {
        get {
            machineBinding.wrappedValue
        } set {
            machineBinding.wrappedValue = newValue
            self.objectWillChange.send()
        }
    }
    
    let path: Attributes.Path<Machine, Action>
    
    var action: Action {
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
    
    weak var notifier: GlobalChangeNotifier?
    
    @Published var collapsed: Bool
    
    var errors: [String] {
        get {
            machine.errorBag.errors(forPath: path).map(\.message)
        } set {}
    }
    
    var name: String {
        get {
            action.name
        }
        set {
            let result = machine.modify(attribute: path.name, value: newValue)
            guard let notifier = notifier, let hasTrigger = try? result.get(), hasTrigger == true else {
                self.objectWillChange.send()
                return
            }
            notifier.send()
        }
    }
    
    var implementation: Code {
        get {
            action.implementation
        }
        set {
            let result = machine.modify(attribute: path.implementation, value: newValue)
            guard let notifier = notifier, let hasTrigger = try? result.get(), hasTrigger == true else {
                self.objectWillChange.send()
                return
            }
            notifier.send()
        }
    }
    
    var language: Language {
        get {
            action.language
        } set {
            let result = machine.modify(attribute: path.language, value: newValue)
            guard let notifier = notifier, let hasTrigger = try? result.get(), hasTrigger == true else {
                self.objectWillChange.send()
                return
            }
            notifier.send()
        }
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Action>, notifier: GlobalChangeNotifier? = nil, collapsed: Bool = false) {
        self.machineBinding = machine
        self.path = path
        self.notifier = notifier
        self.collapsed = collapsed
    }
    
}
