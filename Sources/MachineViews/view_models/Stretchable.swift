//
//  Stretchable.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

protocol Stretchable: Rigidable {
    
    var isStretchingX: Bool { get set }
    
    var isStretchingY: Bool { get set }
    
    mutating func stretchCorner(gesture: DragGesture.Value)
    
    mutating func stretchHorizontal(gesture: DragGesture.Value)
    
    mutating func stretchVertical(gesture: DragGesture.Value)
    
}
