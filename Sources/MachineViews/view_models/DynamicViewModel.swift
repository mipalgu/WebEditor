//
//  DynamicViewModel.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

protocol DynamicViewModel: Positionable, Collapsable, Dragable {
    
    mutating func handleCollapsedDrag(gesture: DragGesture.Value)
    
    mutating func finishCollapsedDrag(gesture: DragGesture.Value)
    
}
