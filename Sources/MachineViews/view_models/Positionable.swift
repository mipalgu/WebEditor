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

protocol Positionable: class {
    
    var location: CGPoint {get set}
    
}
