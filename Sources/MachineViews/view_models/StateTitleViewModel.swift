//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import TokamakShim
import Foundation
import AttributeViews
import Attributes
import Machines

final class StateTitleViewModel: ObservableObject {
    
    private var machine: Binding<Machine>
    
    let path: Attributes.Path<Machine, StateName>
    
    weak var notifier: GlobalChangeNotifier?
    
    var cache: ViewCache
    
    var name: String {
        get {
            path.isNil(machine.wrappedValue) ? "" : machine.wrappedValue[keyPath: path.path]
        } set {
            let oldName = self.name
            let result = machine.wrappedValue.modify(attribute: path, value: newValue)
            guard let hasTrigger = try? result.get() else {
                self.objectWillChange.send()
                return
            }
            self.cache.renameState(oldName: oldName, newName: StateName(name))
            guard let notifier = notifier, hasTrigger == true else {
                self.objectWillChange.send()
                return
            }
            notifier.send()
        }
    }
    
    var errors: [String] {
        get {
            machine.wrappedValue.errorBag.errors(forPath: path).map(\.message)
        } set {}
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, StateName>, cache: ViewCache, notifier: GlobalChangeNotifier? = nil) {
        self.machine = machine
        self.path = path
        self.notifier = notifier
        self.cache = cache
    }
    
}
