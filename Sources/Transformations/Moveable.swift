//
//  Moveable.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

import TokamakShim

public protocol Moveable: Positionable {
    
    var offset: CGPoint {get set}
    
    mutating func updateLocationWithOffset(frameWidth: CGFloat, frameHeight: CGFloat, newLocation: CGPoint)
    
}
