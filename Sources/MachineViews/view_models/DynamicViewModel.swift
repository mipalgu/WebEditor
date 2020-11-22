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
    
    func handleCollapsedDrag(gesture: DragGesture.Value)
    
    func finishCollapsedDrag(gesture: DragGesture.Value)
    
}
