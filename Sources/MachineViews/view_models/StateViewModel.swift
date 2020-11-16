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
    
    @Published var _machine: Ref<Machine>
    
    var machine: Machine {
        get {
            _machine.value
        }
        set {
            _machine.value = newValue
            self.objectWillChange.send()
        }
    }
    
    let path: Attributes.Path<Machine, Machines.State>
    
    @Published var location: CGPoint
    
    @Published fileprivate var _width: CGFloat
    
    @Published fileprivate var _height: CGFloat
    
    @Published var expanded: Bool
    
    @Published fileprivate var _collapsedWidth: CGFloat
    
    @Published fileprivate var _collapsedHeight: CGFloat
    
    @Published var collapsedActions: [String: Bool]
    
    var collapsedWidth: CGFloat {
        get {
            min(max(collapsedMinWidth, _collapsedWidth), collapsedMaxWidth)
        }
        set {
            let newWidth = min(max(collapsedMinWidth, newValue), collapsedMaxWidth)
            _collapsedWidth = newWidth
            _collapsedHeight = collapsedMinHeight / collapsedMinWidth * newWidth
        }
    }
    
    var collapsedHeight: CGFloat {
        get {
            min(max(collapsedMinHeight, _collapsedHeight), collapsedMaxHeight)
        }
        set {
            let newHeight = min(max(collapsedMinHeight, newValue), collapsedMaxHeight)
            _collapsedHeight = newHeight
            _collapsedWidth = collapsedMinWidth / collapsedMinHeight * newHeight
        }
    }
    
    let collapsedMinWidth: CGFloat = 150.0
    
    let collapsedMinHeight: CGFloat = 100.0
    
    let collapsedMaxWidth: CGFloat = 750.0
    
    let collapsedMaxHeight: CGFloat = 500.0
    
    let minTitleHeight: CGFloat = 42.0
    
    let maxTitleHeight: CGFloat = 42.0
    
    var minTitleWidth: CGFloat {
        elementMinWidth - buttonSize
    }
    
    var maxTitleWidth: CGFloat {
        elementMaxWidth - buttonSize
    }
    
    let minWidth: CGFloat = 200.0
    
    let maxWidth: CGFloat = 1200.0
    
    var minHeight: CGFloat {
        CGFloat(actions.count) * minActionHeight + minTitleHeight + bottomPadding + topPadding + 20.0
    }
    
    let maxHeight: CGFloat = 1200.0
    
    let minEditWidth: CGFloat = 800.0
    
    let topPadding: CGFloat = 10.0
    
    let leftPadding: CGFloat = 20.0
    
    let rightPadding: CGFloat = 20.0
    
    let bottomPadding: CGFloat = 20.0
    
    let buttonSize: CGFloat = 8.0
    
    let buttonDimensions: CGFloat = 15.0
    
    let minActionHeight: CGFloat = 80.0
    
    var width: CGFloat {
        get {
            min(max(_width, minWidth), maxWidth)
        }
        set {
            _width = min(max(minWidth, newValue), maxWidth)
        }
    }

    var height: CGFloat {
        get {
            min(max(_height, minHeight), maxHeight)
        }
        set {
            _height = min(max(minHeight, newValue), maxHeight)
        }
    }
    
    var name: String {
        String(machine[keyPath: path.path].name)
    }
    
    var actions: [Machines.Action] {
        machine[keyPath: path.path].actions
    }
    
    var attributes: [AttributeGroup] {
        machine[keyPath: path.path].attributes
    }
    
    var elementMinWidth: CGFloat {
        minWidth - leftPadding - rightPadding
    }
    
    var elementMaxWidth: CGFloat {
        width - leftPadding - rightPadding
    }
    
    var elementMinHeight: CGFloat {
        minHeight - topPadding - bottomPadding
    }
    
    var elementMaxHeight: CGFloat {
        height - topPadding - bottomPadding
    }
    
    var isAccepting: Bool {
        machine[keyPath: path.path].transitions(in: machine).count == 0
    }
    
    var isEmpty: Bool {
        return nil == actions.first { !$0.implementation.isEmpty }
    }
    
    var actionsMaxHeight: CGFloat {
        elementMaxHeight - maxTitleHeight
    }
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machines.State>, location: CGPoint = CGPoint(x: 75, y: 100), width: CGFloat = 75.0, height: CGFloat = 100.0, expanded: Bool = false, collapsedHeight: CGFloat = 100.0, collapsedActions: [String: Bool] = [:]) {
        self._machine = machine
        self.path = path
        self.location = location
        self._width = min(max(minWidth, width), maxWidth)
        self._height = height
        self.expanded = expanded
        self._collapsedHeight = collapsedHeight
        self._collapsedWidth = collapsedMinWidth / collapsedMinHeight * collapsedHeight
        self.collapsedActions = collapsedActions
    }
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machines.State>, location: CGPoint = CGPoint(x: 75, y: 100), width: CGFloat = 75.0, height: CGFloat = 100.0, expanded: Bool = false, collapsedWidth: CGFloat = 150.0, collapsedActions: [String: Bool] = [:]) {
        self._machine = machine
        self.path = path
        self.location = location
        self._width = min(max(minWidth, width), maxWidth)
        self._height = height
        self.expanded = expanded
        self._collapsedWidth = collapsedWidth
        self._collapsedHeight = collapsedMinHeight / collapsedMinWidth * collapsedWidth
        self.collapsedActions = collapsedActions
    }
    
    public convenience init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machines.State>, location: CGPoint = CGPoint(x: 75, y: 100), width: CGFloat = 75.0, height: CGFloat = 100.0, expanded: Bool = false) {
        self.init(machine: machine, path: path, location: location, width: width, height: height, expanded: expanded, collapsedWidth: 150.0)
    }
    
    func isEmpty(forAction action: String) -> Bool {
        machine[keyPath: path.path].actions.first { $0.name == action }?.implementation.isEmpty ?? true
    }
    
    func toggleExpand() {
        expanded = !expanded
    }
    
}
