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

final class RigidMoveableViewModel: ObservableObject, MoveFromDrag, Rigidable {
    
    @Published var width: CGFloat
    
    @Published var height: CGFloat
    
    @Published var location: CGPoint
    
    var isDragging: Bool = false
    
    var offset: CGPoint = .zero
    
    init(location: CGPoint, width: CGFloat = 10.0, height: CGFloat = 10.0) {
        self.location = location
        self.width = width
        self.height = height
    }
    
}
