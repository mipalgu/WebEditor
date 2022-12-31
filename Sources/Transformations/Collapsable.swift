//
//  Collapsable.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

import GUUI
import Foundation

public protocol Collapsable: Moveable, BoundedSize  {
    
    var expanded: Bool {get set}
    
    var collapsedWidth: CGFloat {get set}
    
    var collapsedHeight: CGFloat {get set}
    
    var expandedWidth: CGFloat { get set }
    
    var expandedHeight: CGFloat { get set }
    
    var expandedMinWidth: CGFloat {get}
    
    var expandedMaxWidth: CGFloat {get}
    
    var expandedMinHeight: CGFloat {get}
    
    var expandedMaxHeight: CGFloat {get}
    
    var collapsedMinWidth: CGFloat {get}
    
    var collapsedMaxWidth: CGFloat {get}
    
    var collapsedMinHeight: CGFloat {get}
    
    var collapsedMaxHeight: CGFloat {get}
    
    func toggleExpand(frameWidth: CGFloat, frameHeight: CGFloat)
    
}
