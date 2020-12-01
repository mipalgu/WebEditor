//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

public protocol _Collapsable: class {
    
    var _collapsedWidth: CGFloat {get set}
    
    var _collapsedHeight: CGFloat {get set}
    
}

public extension Collapsable where Self: _Collapsable {
    
    var bottom: CGPoint {
        if expanded {
            return CGPoint(x: location.x, y: location.y + height / 2.0)
        }
        return CGPoint(x: location.x, y: location.y + collapsedHeight / 2.0)
    }
    
    var top: CGPoint {
        if expanded {
            return CGPoint(x: location.x, y: location.y - height / 2.0)
        }
        return CGPoint(x: location.x, y: location.y - collapsedHeight / 2.0)
    }
    
    var right: CGPoint {
        if expanded {
            return CGPoint(x: location.x + width / 2.0, y: location.y)
        }
        return CGPoint(x: location.x + collapsedWidth / 2.0, y: location.y)
    }
    
    var left: CGPoint {
        if expanded {
            return CGPoint(x: location.x - width / 2.0, y: location.y)
        }
        return CGPoint(x: location.x - collapsedWidth / 2.0, y: location.y)
    }
    
    var collapsedWidth: CGFloat {
        get {
            min(max(collapsedMinWidth, _collapsedWidth), collapsedMaxWidth)
        }
        set {
            let newWidth = min(max(collapsedMinWidth, newValue), collapsedMaxWidth)
            _collapsedWidth = newWidth
            _collapsedHeight = collapsedMinHeight / collapsedMinWidth * newWidth
        }
    }
    
    var collapsedHeight: CGFloat {
        get {
            min(max(collapsedMinHeight, _collapsedHeight), collapsedMaxHeight)
        }
        set {
            let newHeight = min(max(collapsedMinHeight, newValue), collapsedMaxHeight)
            _collapsedHeight = newHeight
            _collapsedWidth = collapsedMinWidth / collapsedMinHeight * newHeight
        }
    }
    
    func toggleExpand(frameWidth: CGFloat, frameHeight: CGFloat) {
        self.expanded = !self.expanded
        self.setLocation(width: frameWidth, height: frameHeight, newLocation: self.location)
    }
    
    func getLocation(width: CGFloat, height: CGFloat) -> CGPoint {
        let x = self.location.x
        let y = self.location.y
        if expanded {
            return CGPoint(
                x: min(max(self.width / 2.0, x), width - self.width / 2.0),
                y: min(max(self.height / 2.0, y), height - self.height / 2.0)
            )
        }
        return CGPoint(
            x: min(max(self.collapsedWidth / 2.0, x), width - self.collapsedWidth / 2.0),
            y: min(max(self.collapsedHeight / 2.0, y), height - self.collapsedHeight / 2.0)
        )
    }
    
    func setLocation(width: CGFloat, height: CGFloat, newLocation: CGPoint) {
        let x = newLocation.x
        let y = newLocation.y
        if expanded {
            self.location = CGPoint(
                x: min(max(self.width / 2.0, x), width - self.width / 2.0),
                y: min(max(self.height / 2.0, y), height - self.height / 2.0)
            )
            return
        }
        self.location = CGPoint(
            x: min(max(self.collapsedWidth / 2.0, x), width - self.collapsedWidth / 2.0),
            y: min(max(self.collapsedHeight / 2.0, y), height - self.collapsedHeight / 2.0)
        )
    }
    
}