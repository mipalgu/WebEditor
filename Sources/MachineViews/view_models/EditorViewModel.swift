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
    
    @Published public var errorLog: [Error]
    
    public let logSize: UInt16
    
    public var currentMachine: MachineViewModel {
        machines[currentMachineIndex]
    }
    
    public var log: String {
        errorLog.map { $0.localizedDescription }.reduce("") {
            if $0 == "" {
                return $1
            }
            if $1 == "" {
                return $0
            }
            return $0 + "\n" + $1
        }
    }
    
    public init(machines: [MachineViewModel], mainView: ViewType = .none, focusedView: ViewType = .none, currentMachineIndex: Int = 0, logSize: UInt16 = 50) {
        self.machines = machines
        self.mainView = mainView
        self.focusedView = focusedView
        self.currentMachineIndex = currentMachineIndex
        self.logSize = logSize
        self.errorLog = []
        self.errorLog.reserveCapacity(Int(logSize))
    }
    
    public func changeFocus(machine: UUID, stateIndex: Int) {
        guard nil != self.state(machine: machine, stateIndex: stateIndex) else {
            return
        }
        self.focusedView = .state(machine: machine, stateIndex: stateIndex)
    }
    
    public func changeFocus(machine: UUID) {
        guard nil != self.machine(id: machine) else {
            return
        }
        self.focusedView = .machine(id: machine)
    }
    
    public func changeMainView(machine: UUID, stateIndex: Int) {
        guard nil != self.state(machine: machine, stateIndex: stateIndex) else {
            return
        }
        self.mainView = .state(machine: machine, stateIndex: stateIndex)
    }
    
    public func changeMainView(machine: UUID) {
        guard nil != self.machine(id: machine) else {
            return
        }
        self.mainView = .machine(id: machine)
    }
    
    public func machine(id: UUID) -> MachineViewModel? {
        machines.first { $0.id == id }
    }
    
    public func state(machine: UUID, stateIndex: Int) -> StateViewModel? {
        self.machine(id: machine)?.states[stateIndex]
    }
    
    public func addError(error: Error) {
        if errorLog.count > logSize {
            let _ = errorLog.popLast()
        }
        errorLog.insert(error, at: 0)
    }
    
}
