//
//  StateViewModel.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

public class StateViewModel: ObservableObject {
    
    @Published var machine: Machine
    
    let path: Attributes.Path<Machine, Machines.State>
    
    @Published var location: CGPoint
    
    @Published fileprivate var _width: CGFloat
    
    @Published fileprivate var _height: CGFloat
    
    @Published var expanded: Bool
    
    let collapsedWidth: CGFloat = 150.0
    
    let collapsedHeight: CGFloat = 100.0
    
    let minWidth: CGFloat = 75.0
    
    let minHeight: CGFloat = 100.0
    
    let minDetailsWidth: CGFloat = 100.0
    
    let maxDetailsWidth: CGFloat = 400.0
    
    let minEditWidth: CGFloat = 800.0
    
    let minActionHeight: CGFloat = 200.0
    
    var width: CGFloat {
        get {
            _width
        }
        set {
            _width = max(minWidth, newValue)
        }
    }

    var height: CGFloat {
        get {
            _height
        }
        set {
            _height = max(minHeight, newValue)
        }
    }
    
    var name: String {
        String(machine[keyPath: path.path].name)
    }
    
    var actions: [(String, String)] {
        machine[keyPath: path.path].actions.sorted { $0.0 < $1.0 }
    }
    
    var attributes: [AttributeGroup] {
        machine[keyPath: path.path].attributes
    }
    
    public init(machine: Machine, path: Attributes.Path<Machine, Machines.State>, location: CGPoint = CGPoint(x: 75, y: 100), width: CGFloat = 75.0, height: CGFloat = 100.0, expanded: Bool = false) {
        self.machine = machine
        self.path = path
        self.location = location
        self._width = max(minWidth, width)
        self._height = height
        self.expanded = expanded
    }
    
}
