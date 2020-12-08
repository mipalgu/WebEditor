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

public protocol Rigidable: Positionable {
    
    var width: CGFloat { get set }
    
    var height: CGFloat { get set }
    
    var bottom: CGPoint {get}
    
    var top: CGPoint {get}
    
    var right: CGPoint {get}
    
    var left: CGPoint {get}
    
    func isWithin(point: CGPoint) -> Bool
    
    func findEdge(degrees: CGFloat) -> CGPoint
    
    func findEdge(radians: CGFloat) -> CGPoint
    
    func findEdgeCenter(degrees: CGFloat) -> CGPoint
    
    func findEdgeCenter(radians: CGFloat) -> CGPoint
    
    func findEdgeCenter(point: CGPoint) -> CGPoint
    
    func closestEdge(point: CGPoint) -> CGPoint
    
    func closestPointToEdge(point: CGPoint, degrees: CGFloat) -> CGPoint
    
    func closestPointToEdge(point: CGPoint, radians: CGFloat) -> CGPoint
    
    func closestPointToEdge(point: CGPoint, source: CGPoint) -> CGPoint
}
