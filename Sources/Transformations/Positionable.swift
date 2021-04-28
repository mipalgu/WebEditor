//
//  Positionable.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

import TokamakShim

public protocol Positionable {
    
    var location: CGPoint {get set}
    
    func getLocation(width: CGFloat, height: CGFloat) -> CGPoint
    
    mutating func setLocation(width: CGFloat, height: CGFloat, newLocation: CGPoint)
    
}
