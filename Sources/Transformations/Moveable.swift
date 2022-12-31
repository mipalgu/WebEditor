//
//  Moveable.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

import GUUI
import Foundation

public protocol Moveable: Positionable {
    
    var offset: CGPoint {get set}
    
    func updateLocationWithOffset(frameWidth: CGFloat, frameHeight: CGFloat, newLocation: CGPoint)
    
}
