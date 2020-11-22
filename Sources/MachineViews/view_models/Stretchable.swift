//
//  Stretchable.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

protocol Stretchable {
    
    var width: CGFloat {get set}
    
    var height: CGFloat {get set}
    
    var minWidth: CGFloat {get}
    
    var maxWidth: CGFloat {get}
    
    var minHeight: CGFloat {get}
    
    var maxHeight: CGFloat {get}
    
    var isStretchingX: Bool {get set}
    
    var isStretchingY: Bool {get set}
    
    func stretchHorizontal(gesture: DragGesture.Value)
    
    func stretchVertical(gesture: DragGesture.Value)
    
}
