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
    
    public init(machines: [MachineViewModel], mainView: ViewType = .none, focusedView: ViewType = .none) {
        self.machines = machines
        self.mainView = mainView
        self.focusedView = focusedView
    }
    
    public func changeFocus(machine: String, state: String) {
        guard let newFocus = (machines.first { $0.name == machine }?.states.firstIndex { $0.name == state }) else {
            return
        }
        self.focusedView = .state(stateIndex: newFocus)
    }
    
    public func changeFocus(machine: String) {
        guard nil != (machines.first { $0.name == machine }) else {
            return
        }
        self.focusedView = .machine
    }
    
    public func changeMainView(machine: String, state: String) {
        guard let newFocus = (machines.first { $0.name == machine }?.states.firstIndex { $0.name == state }) else {
            return
        }
        self.mainView = .state(stateIndex: newFocus)
    }
    
    public func changeMainView(machine: String) {
        guard nil != (machines.first { $0.name == machine }) else {
            return
        }
        self.mainView = .machine
    }
    
}
