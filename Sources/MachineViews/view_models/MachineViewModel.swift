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

import Combine

public class MachineViewModel: ObservableObject {
    
    @Reference public var machine: Machine
    
    @Published public var states: [StateViewModel]
    
    public var path: Attributes.Path<Machine, Machine> {
        machine.path
    }
    
    public var name: String {
        machine[keyPath: path.path].name
    }
    
    public var id: UUID {
        machine.id
    }
    
    let gridWidth: CGFloat = 80.0
    
    let gridHeight: CGFloat = 80.0
    
    public init(machine: Ref<Machine>) {
        self._machine = Reference(reference: machine)
        let statesPath: Attributes.Path<Machine, [Machines.State]> = machine.value.path.states
        let states: [Machines.State] = machine.value[keyPath: statesPath.path]
        self.states = states.indices.map {
            StateViewModel(machine: machine, path: machine.value.path.states[$0])
        }
        self.listen(to: $machine)
    }
    
    public func removeHighlights() {
        states.forEach {
            $0.highlighted = false
        }
    }
    
    public func getStateViewModel(stateName: String) -> StateViewModel {
        guard let vm = self.states.first(where: { $0.name == stateName }) else {
            fatalError("Tried to access state view model that didn't exist")
        }
        return vm
    }
    
    public func deleteState(stateViewModel: StateViewModel) {
        /*if !stateViewModel.highlighted {
            return
        }*/
        guard let stateIndex = self.states.firstIndex(of: stateViewModel) else {
            return
        }
        do {
            try self.machine.deleteState(atIndex: stateViewModel.stateIndex)
            self.states.remove(at: stateIndex)
        } catch let error {
            print(error)
        }
    }
    
}
