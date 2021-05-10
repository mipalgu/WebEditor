//
//  MachineViewModel.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import Foundation
import TokamakShim
import AttributeViews
import Attributes
import Machines
import Utilities
import GUUI

final class MachineViewModel: ObservableObject, GlobalChangeNotifier {
    
    var machine: Machine
    
    weak var notifier: GlobalChangeNotifier?
    
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
        return CanvasViewModel(
            machineRef: machineRef,
            layout: (try? String(contentsOf: plistURL)).flatMap { Layout(fromPlistRepresentation: $0) },
            notifier: self
        )
    }()
    
    private var stateIndex: Int = -1
    
    private var transitionIndex: Int = -1
    
    var machineRef: Ref<Machine> {
        Ref(
            get: { self.machine },
            set: { self.machine = $0 }
        )
    }
    
    var selection: Int? {
        get {
            switch focus {
            case .machine:
                return machineSelection.map { $0 >= machine.attributes.count } == true ? nil : machineSelection
            case .state(let index):
                if index >= machine.states.count {
                    return nil
                }
                return stateSelection.map { $0 >= machine.states[index].attributes.count } == true ? nil : stateSelection
            case .transition(let stateIndex, let transitionIndex):
                if stateIndex >= machine.states.count || transitionIndex >= machine.states[stateIndex].transitions.count {
                    return nil
                }
                return transitionSelection.map { $0 >= machine.states[stateIndex].transitions[transitionIndex].attributes.count } == true ? nil : transitionSelection
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
                let path = machine.path.states[stateIndex].attributes
                if !path.isNil(machine) {
                    return path
                }
                return machine.path.attributes
            case .transition(let stateIndex, let transitionIndex):
                let path = machine.path.states[stateIndex].transitions[transitionIndex].attributes
                if !path.isNil(machine) && !machine.states[stateIndex].transitions[transitionIndex].attributes.isEmpty {
                    return path
                }
                let statePath = machine.path.states[stateIndex].attributes
                if !statePath.isNil(machine) && !machine.states[stateIndex].attributes.isEmpty {
                    return statePath
                }
                return machine.path.attributes
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
    
    convenience init?(filePath url: URL, notifier: GlobalChangeNotifier? = nil) {
        guard let machine = try? Machine(filePath: url) else {
            return nil
        }
        self.init(machine: machine, notifier: notifier)
    }
    
    init(machine: Machine, notifier: GlobalChangeNotifier? = nil) {
        self.machine = machine
        self.notifier = notifier
    }
    
    func send() {
        canvasViewModel.objectWillChange.send()
        self.objectWillChange.send()
        notifier?.send()
    }
    
}
