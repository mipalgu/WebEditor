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
    
    @Published fileprivate var _width: Double
    
    @Published fileprivate var _height: Double
    
    @Published var expanded: Bool
    
    @Published fileprivate var _detailsWidth: Double
    
    let collapsedWidth: Double = 150.0
    
    let collapsedHeight: Double = 100.0
    
    let minWidth: Double = 75.0
    
    let minHeight: Double = 100.0
    
    let minDetailsWidth: Double = 200.0
    
    var width: Double {
        get {
            _width
        }
        set {
            _width = max(minWidth, newValue)
        }
    }

    var height: Double {
        get {
            _height
        }
        set {
            _height = max(minHeight, newValue)
        }
    }
    
    var detailsWidth: Double {
        get {
            _detailsWidth
        }
        set {
            _detailsWidth = max(minDetailsWidth, newValue)
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
    
    var actionHeight: Double {
        floor((min(self.height * 11.0 / 12.0, self.height - 48.0)) / Double(actions.count)) - 40.0 / Double(actions.count)
    }
    
    var titleHeight: Double {
        //max(floor(self.height / 12.0), 42.0)
        42.0
    }
    
    var titleWidth: Double {
        width - 40.0
    }
    
    public init(machine: Machine, path: Attributes.Path<Machine, Machines.State>, location: CGPoint = CGPoint(x: 75, y: 100), width: Double = 75.0, height: Double = 100.0, expanded: Bool = false, detailsWidth: Double = 200.0) {
        self.machine = machine
        self.path = path
        self.location = location
        self._width = max(minWidth, width)
        self._height = height
        self.expanded = expanded
        self._detailsWidth = detailsWidth
    }
    
    func editActionHeight(frameHeight: Double) -> Double {
        floor((min(frameHeight * 11.0 / 12.0, frameHeight - 48.0)) / Double(actions.count)) - 40.0 / Double(actions.count)
    }
    
}
