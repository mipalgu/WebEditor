//
//  TransitionControlPointViewModel.swift
//  
//
//  Created by Morgan McColl on 27/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

public final class RigidMoveableViewModel: ObservableObject, MoveFromDrag, Rigidable {
    
    @Published public var width: CGFloat
    
    @Published public var height: CGFloat
    
    @Published public var location: CGPoint
    
    public var isDragging: Bool = false
    
    public var offset: CGPoint = .zero
    
    public init(location: CGPoint, width: CGFloat = 10.0, height: CGFloat = 10.0) {
        self.location = location
        self.width = width
        self.height = height
    }
    
}
