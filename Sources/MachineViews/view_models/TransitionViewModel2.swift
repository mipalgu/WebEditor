//
//  File.swift
//  
//
//  Created by Morgan McColl on 18/4/21.
//

import Foundation
import Transformations

struct TransitionViewModel2: Identifiable  {
    
    var id: UUID = UUID()
        
    var point0: CGPoint
    
    var point1: CGPoint
    
    var point2: CGPoint
    
    var point3: CGPoint
    
    init(point0: CGPoint, point1: CGPoint, point2: CGPoint, point3: CGPoint) {
        self.point0 = point0
        self.point1 = point1
        self.point2 = point2
        self.point3 = point3
    }
    
    init(source: CGPoint, target: CGPoint) {
        self.point0 = source
        self.point3 = target
        let middle = CGPoint(
            x: (target.x - source.x) / 2.0 + source.x,
            y: (target.y - source.y) / 2.0 + source.y
        )
        let quarter = CGPoint(
            x: (middle.x - source.x) / 2.0,
            y: (middle.y - source.y) / 2.0
        )
        self.point1 = CGPoint(
            x: source.x + quarter.x,
            y: source.y + quarter.y
        )
        self.point2 = CGPoint(
            x: target.x - quarter.x,
            y: target.y - quarter.y
        )
    }
    
}
