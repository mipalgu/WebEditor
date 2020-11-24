//
//  File.swift
//  
//
//  Created by Morgan McColl on 25/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

protocol _BoundedSize: class {
    
    var _width: CGFloat { get set }
    
    var _height: CGFloat { get set }
    
}

extension BoundedSize where Self: _BoundedSize & Rigidable {
    
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
