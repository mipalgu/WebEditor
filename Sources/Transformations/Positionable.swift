//
//  Positionable.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

import GUUI
import Foundation

public protocol Positionable: AnyObject {
    
    var location: CGPoint {get set}
    
    func getLocation(width: CGFloat, height: CGFloat) -> CGPoint
    
    func setLocation(width: CGFloat, height: CGFloat, newLocation: CGPoint)
    
}
