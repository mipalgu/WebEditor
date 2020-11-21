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

public class MachineViewModel: ObservableObject {
    
    @Published var machine: Ref<Machine>
    
    @Published var states: [StateViewModel]
    
    let path: Attributes.Path<Machine, Machine>
    
    var name: String {
        machine.value[keyPath: path.path].name
    }
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machine>, states: [StateViewModel]) {
        self.machine = machine
        self.path = path
        self.states = states
    }
    
}
