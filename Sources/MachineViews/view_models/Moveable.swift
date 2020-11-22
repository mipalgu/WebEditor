//
//  Moveable.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

protocol Moveable: Positionable {
    
    var offset: CGPoint {get set}
    
    func updateLocationWithOffset(newLocation: CGPoint)
    
}
