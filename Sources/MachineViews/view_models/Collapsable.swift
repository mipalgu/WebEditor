//
//  Collapsable.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

protocol Collapsable: Stretchable {
    
    var expanded: Bool {get set}
    
    var collapsedWidth: CGFloat {get set}
    
    var collapsedHeight: CGFloat {get set}
    
    var collapsedMinWidth: CGFloat {get}
    
    var collapsedMaxWidth: CGFloat {get}
    
    var collapsedMinHeight: CGFloat {get}
    
    var collapsedMaxHeight: CGFloat {get}
    
    func toggleExpand()
    
}
