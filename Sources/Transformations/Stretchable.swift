//
//  Stretchable.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

import TokamakShim

public protocol Stretchable: EdgeDetector {
    
    var isStretchingX: Bool { get set }
    
    var isStretchingY: Bool { get set }
    
    mutating func stretchCorner(gesture: DragGesture.Value)
    
    mutating func stretchHorizontal(gesture: DragGesture.Value)
    
    mutating func stretchVertical(gesture: DragGesture.Value)
    
}
