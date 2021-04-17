//
//  File.swift
//  
//
//  Created by Morgan McColl on 17/4/21.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Transformations
import Utilities

class StateViewModel2: ObservableObject, Identifiable, Equatable, MoveAndStretchFromDrag, _Collapsable, Collapsable {
    
    @Binding public var machine: Machine
    
    public let path: Attributes.Path<Machine, Machines.State>
    
    @Published var isDragging: Bool = false
    
    @Published var _collapsedWidth: CGFloat
    
    @Published var _collapsedHeight: CGFloat
    
    @Published var expanded: Bool
    
    @Published var location: CGPoint
    
    @Published var width: CGFloat
    
    @Published var height: CGFloat
    
    let collapsedMinWidth: CGFloat = 150.0
    
    let collapsedMaxWidth: CGFloat = 750.0
    
    let collapsedMinHeight: CGFloat = 100.0
    
    let collapsedMaxHeight: CGFloat = 500.0
    
    var offset: CGPoint = CGPoint.zero
    
    let minWidth: CGFloat = 200.0
    
    let maxWidth: CGFloat = 1200.0
    
    let minHeight: CGFloat = 300.0
    
    var maxHeight: CGFloat = 600.0
    
    var isStretchingX: Bool = false
    
    var isStretchingY: Bool = false
    
    let horizontalEdgeTolerance: CGFloat = 20.0
    
    let verticalEdgeTolerance: CGFloat = 20.0
    
    static func == (lhs: StateViewModel2, rhs: StateViewModel2) -> Bool {
        lhs === rhs
    }
    
    public init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, location: CGPoint = CGPoint(x: 75, y: 100), width: CGFloat = 75.0, height: CGFloat = 100.0, expanded: Bool = false, collapsedWidth: CGFloat = 150.0, collapsedHeight: CGFloat = 100.0) {
        self._machine = machine
        self.path = path
        self.location = location
        self.width = width
        self.height = height
        self.expanded = expanded
        self._collapsedWidth = collapsedWidth
        self._collapsedHeight = collapsedHeight
    }

}
