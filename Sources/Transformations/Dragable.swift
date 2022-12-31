//
//  Dragable.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

import GUUI
import Foundation

public protocol Dragable: AnyObject {
    
    var isDragging: Bool {get set}
    
    func handleDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat)
    
    func finishDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat)
    
}
