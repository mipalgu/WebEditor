//
//  File.swift
//  
//
//  Created by Morgan McColl on 28/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

class BoundedPositionViewModel: ObservableObject, BoundedPosition, Rigidable, MoveFromDrag {
    
    @Published var location: CGPoint
    
    var width: CGFloat
    
    var height: CGFloat
    
    let minX: CGFloat
    
    let maxX: CGFloat
    
    let minY: CGFloat
    
    let maxY: CGFloat
    
    var isDragging: Bool = false
    
    var offset: CGPoint = .zero
    
    init(location: CGPoint, width: CGFloat, height: CGFloat, minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
        self.location = location
        self.width = width
        self.height = height
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
    }
    
}
