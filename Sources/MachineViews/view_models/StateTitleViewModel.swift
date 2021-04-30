//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import TokamakShim
import Foundation
import Attributes
import Machines

final class StateTitleViewModel: ObservableObject {
    
    private var machine: Binding<Machine>
    
    let path: Attributes.Path<Machine, StateName>
    
    weak var notifier: GlobalChangeNotifier?
    
    var name: String {
        get {
            machine.wrappedValue[keyPath: path.path]
        } set {
            let result = machine.wrappedValue.modify(attribute: path, value: newValue)
            guard let notifier = notifier, let hasTrigger = try? result.get(), hasTrigger == true else {
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
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, StateName>, notifier: GlobalChangeNotifier? = nil) {
        self.machine = machine
        self.path = path
        self.notifier = notifier
    }
    
}
