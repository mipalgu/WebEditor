//
//  EdgeDetector+DefaultImplementation.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

extension EdgeDetector {
    
    func onTopEdge(point: CGPoint) -> Bool {
        let topEdge = self.location.y - height / 2.0
        let topEdgeAbove = topEdge - horizontalEdgeTolerance
        let topEdgeBelow = topEdge + horizontalEdgeTolerance
        let y = point.y
        return y >= topEdgeAbove && y <= topEdgeBelow
    }
    
    func onBottomEdge(point: CGPoint) -> Bool {
        let bottomEdge = self.location.y + height / 2.0
        let bottomEdgeAbove = bottomEdge - horizontalEdgeTolerance
        let bottomEdgeBelow = bottomEdge + horizontalEdgeTolerance
        let y = point.y
        return y >= bottomEdgeAbove && y <= bottomEdgeBelow
    }
    
    func onLeftEdge(point: CGPoint) -> Bool {
        let leftEdge = self.location.x - width / 2.0
        let leftBoundLower = leftEdge - verticalEdgeTolerance
        let leftBoundUpper = leftEdge + verticalEdgeTolerance
        let x = point.x
        return x >= leftBoundLower && x <= leftBoundUpper
    }
    
    func onRightEdge(point: CGPoint) -> Bool {
        let rightEdge = self.location.x + width / 2.0
        let rightBoundLower = rightEdge - verticalEdgeTolerance
        let rightBoundUpper = rightEdge + verticalEdgeTolerance
        let x = point.x
        return x >= rightBoundLower && x <= rightBoundUpper
    }
    
    func onTopRightCorner(point: CGPoint) -> Bool {
        return onTopEdge(point: point) && onRightEdge(point: point)
    }
    
    func onBottomRightCorner(point: CGPoint) -> Bool {
        return onBottomEdge(point: point) && onRightEdge(point: point)
    }
    
    func onBottomLeftCorner(point: CGPoint) -> Bool {
        return onBottomEdge(point: point) && onLeftEdge(point: point)
    }
    
    func onTopLeftCorner(point: CGPoint) -> Bool {
        return onTopEdge(point: point) && onLeftEdge(point: point)
    }
    
    func onCorner(point: CGPoint) -> Bool {
        onTopRightCorner(point: point) || onBottomRightCorner(point: point) ||
            onBottomLeftCorner(point: point) || onTopLeftCorner(point: point)
    }
    
    func onVerticalEdge(point: CGPoint) -> Bool {
        onLeftEdge(point: point) || onRightEdge(point: point)
    }
    
    func onHorizontalEdge(point: CGPoint) -> Bool {
        onTopEdge(point: point) || onBottomEdge(point: point)
    }
    
}
