//
//  EdgeableDetector.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

import TokamakShim
import Foundation

public protocol EdgeDetector: Rigidable {
    
    var horizontalEdgeTolerance: CGFloat {get}

    var verticalEdgeTolerance: CGFloat {get}
    
    func onTopEdge(point: CGPoint) -> Bool
    
    func onBottomEdge(point: CGPoint) -> Bool
    
    func onLeftEdge(point: CGPoint) -> Bool
    
    func onRightEdge(point: CGPoint) -> Bool
    
    func onTopRightCorner(point: CGPoint) -> Bool
    
    func onBottomRightCorner(point: CGPoint) -> Bool
    
    func onBottomLeftCorner(point: CGPoint) -> Bool
    
    func onTopLeftCorner(point: CGPoint) -> Bool
    
    func onCorner(point: CGPoint) -> Bool
    
    func onVerticalEdge(point: CGPoint) -> Bool
    
    func onHorizontalEdge(point: CGPoint) -> Bool
    
    func onEdge(point: CGPoint) -> Bool
    
}
