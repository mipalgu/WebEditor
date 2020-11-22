//
//  Stretchable+DefaultImplementation.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

protocol _BoundedStretchable: class {
    
    var _width: CGFloat { get set }
    
    var _height: CGFloat { get set }
    
}

protocol BoundedStretchable: Stretchable {
    
    var minWidth: CGFloat { get }
    
    var maxWidth: CGFloat { get }
    
    var minHeight: CGFloat { get }
    
    var maxHeight: CGFloat { get }
}

extension BoundedStretchable where Self: _BoundedStretchable {
    
    var width: CGFloat {
        get {
            min(max(self._width, self.minWidth), self.maxWidth)
        }
        set {
            self._width = min(max(self.minWidth, newValue), self.maxWidth)
        }
    }

    var height: CGFloat {
        get {
            min(max(self._height, self.minHeight), self.maxHeight)
        }
        set {
            self._height = min(max(self.minHeight, newValue), self.maxHeight)
        }
    }
    
}
