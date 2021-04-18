//
//  Dragable.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

public protocol Dragable {
    
    var isDragging: Bool {get set}
    
    mutating func handleDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat)
    
    mutating func finishDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat)
    
}
