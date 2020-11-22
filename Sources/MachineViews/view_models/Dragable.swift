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

protocol Dragable: class {
    
    var isDragging: Bool {get set}
    
    func handleDrag(gesture: DragGesture.Value)
    
    func finishDrag(gesture: DragGesture.Value)
    
}
