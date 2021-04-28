//
//  EdgeDetector+DefaultImplementation.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

import TokamakShim

public extension EdgeDetector where Self: Rigidable {
    
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
    
    func onEdge(point: CGPoint) -> Bool {
        onHorizontalEdge(point: point) || onVerticalEdge(point: point)
    }
    
}

public extension EdgeDetector where Self: Collapsable & Rigidable {
    
    private func getAngle(point: CGPoint) -> Double {
        let dx = point.x - location.x
        let dy = point.y - location.y
        return atan2(Double(dy), Double(dx)) / Double.pi * 180.0
    }
    
    private func isWithinTolerance(degrees: CGFloat, point: CGPoint) -> Bool {
        let edge = findEdge(degrees: degrees)
        let dx = abs(point.x - edge.x)
        let dy = abs(point.y - edge.y)
        return dx <= horizontalEdgeTolerance && dy <= verticalEdgeTolerance
    }
    
    private func expandedOnTopEdge(point: CGPoint) -> Bool {
        let topEdge = self.location.y - height / 2.0
        let topEdgeAbove = topEdge - horizontalEdgeTolerance
        let topEdgeBelow = topEdge + horizontalEdgeTolerance
        let y = point.y
        return y >= topEdgeAbove && y <= topEdgeBelow
    }
    
    private func isOnEdge(point: CGPoint, minAngle: Double, maxAngle: Double) -> Bool {
        let angle = getAngle(point: point)
        if angle < minAngle || angle > maxAngle {
            return false
        }
        return isWithinTolerance(degrees: CGFloat(angle), point: point)
    }
    
    private func collapsedOnTopEdge(point: CGPoint) -> Bool {
        isOnEdge(point: point, minAngle: 60.0, maxAngle: 120.0)
    }
    
    private func expandedOnBottomEdge(point: CGPoint) -> Bool {
        let bottomEdge = self.location.y + height / 2.0
        let bottomEdgeAbove = bottomEdge - horizontalEdgeTolerance
        let bottomEdgeBelow = bottomEdge + horizontalEdgeTolerance
        let y = point.y
        return y >= bottomEdgeAbove && y <= bottomEdgeBelow
    }
    
    private func collapsedOnBottomEdge(point: CGPoint) -> Bool {
        isOnEdge(point: point, minAngle: -120.0, maxAngle: -60.0)
    }
    
    private func expandedOnLeftEdge(point: CGPoint) -> Bool {
        let leftEdge = self.location.x - width / 2.0
        let leftBoundLower = leftEdge - verticalEdgeTolerance
        let leftBoundUpper = leftEdge + verticalEdgeTolerance
        let x = point.x
        return x >= leftBoundLower && x <= leftBoundUpper
    }
    
    private func collapsedOnLeftEdge(point: CGPoint) -> Bool {
        let angle = getAngle(point: point)
        if !(angle <= -150 || angle >= 150) {
            return false
        }
        return isWithinTolerance(degrees: CGFloat(angle), point: point)
    }
    
    private func expandedOnRightEdge(point: CGPoint) -> Bool {
        let rightEdge = self.location.x + width / 2.0
        let rightBoundLower = rightEdge - verticalEdgeTolerance
        let rightBoundUpper = rightEdge + verticalEdgeTolerance
        let x = point.x
        return x >= rightBoundLower && x <= rightBoundUpper
    }
    
    private func collapsedOnRightEdge(point: CGPoint) -> Bool {
        isOnEdge(point: point, minAngle: -30.0, maxAngle: 30.0)
    }
    
    private func expandedOnTopRightCorner(point: CGPoint) -> Bool {
        return expandedOnTopEdge(point: point) && expandedOnRightEdge(point: point)
    }
    
    private func collapsedOnTopRightCorner(point: CGPoint) -> Bool {
        isOnEdge(point: point, minAngle: 30.0, maxAngle: 60.0)
    }
    
    private func expandedOnBottomRightCorner(point: CGPoint) -> Bool {
        return expandedOnBottomEdge(point: point) && expandedOnRightEdge(point: point)
    }
    
    private func collapsedOnBottomRightCorner(point: CGPoint) -> Bool {
        isOnEdge(point: point, minAngle: -60.0, maxAngle: -30.0)
    }
    
    private func expandedOnBottomLeftCorner(point: CGPoint) -> Bool {
        return expandedOnBottomEdge(point: point) && expandedOnLeftEdge(point: point)
    }
    
    private func collapsedOnBottomLeftCorner(point: CGPoint) -> Bool {
        isOnEdge(point: point, minAngle: -150.0, maxAngle: -120.0)
    }
    
    private func expandedOnTopLeftCorner(point: CGPoint) -> Bool {
        return expandedOnTopEdge(point: point) && expandedOnLeftEdge(point: point)
    }
    
    private func collapsedOnTopLeftCorner(point: CGPoint) -> Bool {
        isOnEdge(point: point, minAngle: 120.0, maxAngle: 150.0)
    }
    
    func onTopEdge(point: CGPoint) -> Bool {
        if expanded {
            return expandedOnTopEdge(point: point)
        }
        return collapsedOnTopEdge(point: point)
    }
    
    func onBottomEdge(point: CGPoint) -> Bool {
        if expanded {
            return expandedOnBottomEdge(point: point)
        }
        return collapsedOnBottomEdge(point: point)
    }
    
    func onLeftEdge(point: CGPoint) -> Bool {
        if expanded {
            return expandedOnLeftEdge(point: point)
        }
        return collapsedOnLeftEdge(point: point)
    }
    
    func onRightEdge(point: CGPoint) -> Bool {
        if expanded {
            return expandedOnRightEdge(point: point)
        }
        return collapsedOnRightEdge(point: point)
    }
    
    func onTopRightCorner(point: CGPoint) -> Bool {
        if expanded {
            return expandedOnTopRightCorner(point: point)
        }
        return collapsedOnTopRightCorner(point: point)
    }
    
    func onBottomRightCorner(point: CGPoint) -> Bool {
        if expanded {
            return expandedOnBottomEdge(point: point) && expandedOnRightEdge(point: point)
        }
        return collapsedOnBottomRightCorner(point: point)
    }
    
    func onBottomLeftCorner(point: CGPoint) -> Bool {
        if expanded {
            return expandedOnBottomEdge(point: point) && expandedOnLeftEdge(point: point)
        }
        return collapsedOnBottomLeftCorner(point: point)
    }
    
    func onTopLeftCorner(point: CGPoint) -> Bool {
        if expanded {
            return expandedOnTopEdge(point: point) && expandedOnLeftEdge(point: point)
        }
        return collapsedOnTopLeftCorner(point: point)
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
    
    func onEdge(point: CGPoint) -> Bool {
        onHorizontalEdge(point: point) || onVerticalEdge(point: point) || onCorner(point: point)
    }
    
}
