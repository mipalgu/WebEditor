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

protocol Dragable {
    
    var isDragging: Bool {get set}
    
    mutating func handleDrag(gesture: DragGesture.Value)
    
    mutating func finishDrag(gesture: DragGesture.Value)
    
}
