//
//  MachineViewModel.swift
//  
//
//  Created by Morgan McColl on 16/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

class MachineViewModel: ObservableObject {
    
    @Published var _machine: Ref<Machine>
    
    @Published var states: [StateViewModel]
    
    var machine: Machine {
        get {
            _machine.value
        }
        set {
            _machine.value = newValue
            self.objectWillChange.send()
        }
    }
    
    let path: Attributes.Path<Machine, Machine>
    
    init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machine>, states: [StateViewModel]) {
        self._machine = machine
        self.path = path
        self.states = states
    }
    
}
