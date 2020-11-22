//
//  TransitionViewModel.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

class TransitionViewModel: ObservableObject {
    
    @Reference var machine: Machine
    
    let path: Attributes.Path<Machine, Transition>
    
    @Published var point0: CGPoint
    
    @Published var point1: CGPoint
    
    @Published var point2: CGPoint
    
    @Published var point3: CGPoint
    
    @Published var priority: UInt8
    
    var condition: String {
        get {
            String(machine[keyPath: path.path].condition ?? "")
        }
        set {
            do {
                try machine.modify(attribute: path.condition, value: Expression(newValue))
            } catch let error {
                print(error)
            }
        }
    }
    
    init(machine: Ref<Machine>, path: Attributes.Path<Machine, Transition>, point0: CGPoint, point1: CGPoint, point2: CGPoint, point3: CGPoint, priority: UInt8) {
        self._machine = Reference(reference: machine)
        self.path = path
        self.point0 = point0
        self.point1 = point1
        self.point2 = point2
        self.point3 = point3
        self.priority = priority
    }
    
}
