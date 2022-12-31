//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/11/20.
//

import GUUI
import Foundation

public protocol DragableCollapsable: Collapsable {
    
    var isDragging: Bool {get set}
    
    func handleCollapsedDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat)
    
    func finishCollapsedDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat)
    
}
