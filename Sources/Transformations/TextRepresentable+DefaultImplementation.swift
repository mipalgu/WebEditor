//
//  File.swift
//  
//
//  Created by Morgan McColl on 18/4/21.
//

import Foundation

public protocol RigidTextRepresentable: _Rigidable, Rigidable, TextRepresentable {
    
    var textWidth: CGFloat { get set }
    
    var textHeight: CGFloat { get set }
    
}

public protocol RigidCollapsableTextRepresentable: RigidTextRepresentable, Collapsable, _Collapsable {}

public extension RigidTextRepresentable {
    
    var width: CGFloat {
        get {
            if isText {
                return textWidth
            }
            return _width
        }
        set {
            if isText {
                textWidth = newValue
            }
            _width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            if isText {
                return textHeight
            }
            return _height
        }
        set {
            if isText {
                textHeight = newValue
            }
            _height = newValue
        }
    }
    
}

public extension RigidCollapsableTextRepresentable {
    
    var width: CGFloat {
        get {
            if isText {
                return textWidth
            }
            if expanded {
                return _width
            }
            return collapsedWidth
        }
        set {
            if isText {
                textWidth = newValue
                return
            }
            if expanded {
                _width = newValue
                return
            }
            collapsedWidth = newValue
        }
    }
    
    var height: CGFloat {
        get {
            if isText {
                return textHeight
            }
            if expanded {
                return _height
            }
            return collapsedHeight
        }
        set {
            if isText {
                textHeight = newValue
                return
            }
            if expanded {
                _height = newValue
                return
            }
            collapsedHeight = newValue
        }
    }
    
}
