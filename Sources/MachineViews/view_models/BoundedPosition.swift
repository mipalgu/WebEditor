//
//  File.swift
//  
//
//  Created by Morgan McColl on 28/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

protocol BoundedPosition: Positionable {
    
    var minX: CGFloat {get}
    
    var maxX: CGFloat {get}
    
    var minY: CGFloat {get}
    
    var maxY: CGFloat {get}
    
    func boundX(x: CGFloat) -> CGFloat
    
    func boundY(y: CGFloat) -> CGFloat
    
    func boundPoint(point: CGPoint) -> CGPoint
    
}
