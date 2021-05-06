//
//  MachineViewModel.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import Foundation
import TokamakShim
import Attributes
import Machines
import Utilities
import GUUI

final class MachineViewModel: ObservableObject, GlobalChangeNotifier {
    
    var machine: Machine
    
    var machineBinding: Binding<Machine> {
        Binding(
            get: { self.machine },
            set: { self.machine = $0 }
        )
    }
    
    @Published var machineSelection: Int?
    
    @Published var stateSelection: Int?
    
    @Published var transitionSelection: Int?
    
    @Published var focus: Focus = .machine {
        willSet {
            switch newValue {
            case .machine:
                return
            case .state(let index):
                if index != stateIndex {
                    stateSelection = nil
                }
                stateIndex = index
            case .transition(let stateIndex, let transitionIndex):
                if stateIndex != self.stateIndex || transitionIndex != self.transitionIndex {
                    self.transitionSelection = nil
                }
                self.transitionIndex = transitionIndex
            }
        }
    }
    
    @Published var attributesCollapsed: Bool = false
    
    lazy var canvasViewModel: CanvasViewModel = {
        let plistURL = machine.filePath.appendingPathComponent("Layout.plist")
        return CanvasViewModel(machine: machineBinding, plist: try? String(contentsOf: plistURL), notifier: self)
    }()
    
    private var stateIndex: Int = -1
    
    private var transitionIndex: Int = -1
    
    var selection: Int? {
        get {
            switch focus {
            case .machine:
                return machineSelection
            case .state:
                return stateSelection
            case .transition:
                return transitionSelection
            }
        } set {
            switch focus {
            case .machine:
                machineSelection = newValue
            case .state:
                stateSelection = newValue
            case .transition:
                transitionSelection = newValue
            }
        }
    }
    
    var path: Attributes.Path<Machine, [AttributeGroup]> {
        switch focus {
            case .machine:
                return machine.path.attributes
            case .state(let stateIndex):
                return machine.path.states[stateIndex].attributes
            case .transition(let stateIndex, let transitionIndex):
                return machine.path.states[stateIndex].transitions[transitionIndex].attributes
        }
    }
    
    var label: String {
        switch focus {
        case .machine:
            return "Machine: \(machine.name)"
        case .state(let stateIndex):
            return "State: \(machine.states[stateIndex].name)"
        case .transition(let stateIndex, let transitionIndex):
            return "State \(machine.states[stateIndex].name) Transition \(transitionIndex)"
        }
    }
    
    convenience init?(filePath url: URL) {
        guard let machine = try? Machine(filePath: url) else {
            return nil
        }
        self.init(machine: machine)
    }
    
    init(machine: Machine) {
        self.machine = machine
    }
    
    func send() {
        self.objectWillChange.send()
    }
    
}
