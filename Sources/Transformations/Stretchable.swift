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

public protocol Stretchable: EdgeDetector {
    
    var isStretchingX: Bool { get set }
    
    var isStretchingY: Bool { get set }
    
    func stretchCorner(gesture: DragGesture.Value)
    
    func stretchHorizontal(gesture: DragGesture.Value)
    
    func stretchVertical(gesture: DragGesture.Value)
    
}
