//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

public protocol DragableCollapsable: Collapsable {
    
    var isDragging: Bool {get set}
    
    mutating func handleCollapsedDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat)
    
    mutating func finishCollapsedDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat)
    
}
