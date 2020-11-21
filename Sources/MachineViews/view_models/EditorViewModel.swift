//
//  EditorViewModel.swift
//  
//
//  Created by Morgan McColl on 21/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

public class EditorViewModel: ObservableObject {
    
    @Published public var machines: [MachineViewModel]
    
    @Published public var mainView: ViewType = .none
    
    @Published public var focusedView: ViewType = .none
    
    @Published public var currentMachineIndex: Int
    
    public var currentMachine: MachineViewModel {
        machines[currentMachineIndex]
    }
    
    public init(machines: [MachineViewModel], mainView: ViewType = .none, focusedView: ViewType = .none, currentMachineIndex: Int = 0) {
        self.machines = machines
        self.mainView = mainView
        self.focusedView = focusedView
        self.currentMachineIndex = currentMachineIndex
    }
    
    public func changeFocus(machine: UUID, stateIndex: Int) {
        guard nil != self.state(machine: machine, stateIndex: stateIndex) else {
            return
        }
        self.focusedView = .state(stateIndex: stateIndex)
    }
    
    public func changeFocus(machine: UUID) {
        guard nil != self.machine(id: machine) else {
            return
        }
        self.focusedView = .machine
    }
    
    public func changeMainView(machine: UUID, stateIndex: Int) {
        guard nil != self.state(machine: machine, stateIndex: stateIndex) else {
            return
        }
        self.mainView = .state(stateIndex: stateIndex)
    }
    
    public func changeMainView(machine: UUID) {
        guard nil != self.machine(id: machine) else {
            return
        }
        self.mainView = .machine
    }
    
    public func machine(id: UUID) -> MachineViewModel? {
        machines.first { $0.id == id }
    }
    
    public func state(machine: UUID, stateIndex: Int) -> StateViewModel? {
        self.machine(id: machine)?.states[stateIndex]
    }
    
}
