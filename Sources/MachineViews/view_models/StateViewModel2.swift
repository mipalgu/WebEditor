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

struct StateViewModel2: MoveAndStretchFromDrag, _Collapsable, Collapsable {
    
    var isDragging: Bool = false
    
    var _collapsedWidth: CGFloat
    
    var _collapsedHeight: CGFloat
    
    var expanded: Bool
    
    var location: CGPoint
    
    var width: CGFloat
    
    var height: CGFloat
    
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
    
    public init(location: CGPoint = CGPoint(x: 75, y: 100), width: CGFloat = 75.0, height: CGFloat = 100.0, expanded: Bool = false, collapsedWidth: CGFloat = 150.0, collapsedHeight: CGFloat = 100.0) {
        self.location = location
        self.width = width
        self.height = height
        self.expanded = expanded
        self._collapsedWidth = collapsedWidth
        self._collapsedHeight = collapsedHeight
    }

}
