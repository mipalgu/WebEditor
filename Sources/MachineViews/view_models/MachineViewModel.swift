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
    
    public var name: String {
        machine.value[keyPath: path.path].name
    }
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machine>) {
        self.machine = machine
        self.path = path
        let statesPath: Attributes.Path<Machine, [Machines.State]> = path.states
        let states: [Machines.State] = machine.value[keyPath: statesPath.path]
        self.states = states.indices.map {
            StateViewModel(machine: machine, path: path.states[$0])
        }
         
    }
    
    public func removeHighlights() {
        states.forEach {
            $0.highlighted = false
        }
    }
    
}
