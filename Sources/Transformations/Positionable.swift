//
//  Positionable.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

public protocol Positionable {
    
    var location: CGPoint {get set}
    
    func getLocation(width: CGFloat, height: CGFloat) -> CGPoint
    
    mutating func setLocation(width: CGFloat, height: CGFloat, newLocation: CGPoint)
    
}
