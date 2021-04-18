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

struct StateViewModel2: MoveAndStretchFromDrag, _Collapsable, Collapsable, EdgeDetector, TextRepresentable, BoundedSize, _Rigidable {
    
    var isText: Bool
    
    var isDragging: Bool = false
    
    var _collapsedWidth: CGFloat
    
    var _collapsedHeight: CGFloat
    
    var expanded: Bool
    
    var location: CGPoint

    let collapsedMinWidth: CGFloat = 150.0
    
    let collapsedMaxWidth: CGFloat = 750.0
    
    let collapsedMinHeight: CGFloat = 100.0
    
    let collapsedMaxHeight: CGFloat = 500.0
    
    var _expandedWidth: CGFloat
    
    var _expandedHeight: CGFloat
    
    var offset: CGPoint = CGPoint.zero
    
    let expandedMinWidth: CGFloat = 200.0
    
    let expandedMaxWidth: CGFloat = 1200.0
    
    let expandedMinHeight: CGFloat = 300.0
    
    var expandedMaxHeight: CGFloat = 600.0
    
    var isStretchingX: Bool = false
    
    var isStretchingY: Bool = false
    
    let horizontalEdgeTolerance: CGFloat = 20.0
    
    let verticalEdgeTolerance: CGFloat = 20.0
    
    var collapsedActions: [String: Bool] = [:]
    
    public init(location: CGPoint = CGPoint(x: 75, y: 100), expandedWidth: CGFloat = 75.0, expandedHeight: CGFloat = 100.0, expanded: Bool = false, collapsedWidth: CGFloat = 150.0, collapsedHeight: CGFloat = 100.0, isText: Bool = false) {
        self.location = location
        self._expandedWidth = expandedWidth
        self._expandedHeight = expandedHeight
        self.expanded = expanded
        self._collapsedWidth = collapsedWidth
        self._collapsedHeight = collapsedHeight
        self.isText = isText
    }

}
