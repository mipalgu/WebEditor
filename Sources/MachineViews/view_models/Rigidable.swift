//
//  Rigidable.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

protocol Rigidable: Positionable {
    
    var width: CGFloat { get set }
    
    var height: CGFloat { get set }
    
}
