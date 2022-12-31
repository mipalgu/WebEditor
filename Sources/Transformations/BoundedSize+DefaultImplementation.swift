//
//  File.swift
//  
//
//  Created by Morgan McColl on 25/11/20.
//

import GUUI
import Foundation

public extension BoundedSize where Self: _Rigidable & Rigidable {
    
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
