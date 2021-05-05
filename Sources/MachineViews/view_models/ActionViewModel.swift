//
//  ActionViewModel.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import Foundation
import TokamakShim
import Attributes
import Machines

final class ActionViewModel: ObservableObject, Hashable {
    
    static func == (lhs: ActionViewModel, rhs: ActionViewModel) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
    
    var machine: Binding<Machine>
    
    let path: Attributes.Path<Machine, Action>
    
    var action: Binding<Action>
    
    weak var notifier: GlobalChangeNotifier?
    
    @Published var collapsed: Bool
    
    var errors: [String] {
        get {
            machine.wrappedValue.errorBag.errors(forPath: path).map(\.message)
        } set {}
    }
    
    var name: String {
        get {
            action.wrappedValue.name
        }
        set {
            let result = machine.wrappedValue.modify(attribute: path.name, value: newValue)
            guard let notifier = notifier, let hasTrigger = try? result.get(), hasTrigger == true else {
                self.objectWillChange.send()
                return
            }
            notifier.send()
        }
    }
    
    var implementation: Code {
        get {
            action.wrappedValue.implementation
        }
        set {
            let result = machine.wrappedValue.modify(attribute: path.implementation, value: newValue)
            guard let notifier = notifier, let hasTrigger = try? result.get(), hasTrigger == true else {
                self.objectWillChange.send()
                return
            }
            notifier.send()
        }
    }
    
    var language: Language {
        get {
            action.wrappedValue.language
        } set {
            let result = machine.wrappedValue.modify(attribute: path.language, value: newValue)
            guard let notifier = notifier, let hasTrigger = try? result.get(), hasTrigger == true else {
                self.objectWillChange.send()
                return
            }
            notifier.send()
        }
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Action>, action: Binding<Action>, notifier: GlobalChangeNotifier? = nil, collapsed: Bool = false) {
        self.machine = machine
        self.path = path
        self.action = action
        self.notifier = notifier
        self.collapsed = collapsed
    }
    
}
