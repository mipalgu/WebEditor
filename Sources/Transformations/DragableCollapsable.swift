//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/11/20.
//

import TokamakShim

public protocol DragableCollapsable: Collapsable {
    
    var isDragging: Bool {get set}
    
    mutating func handleCollapsedDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat)
    
    mutating func finishCollapsedDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat)
    
}
