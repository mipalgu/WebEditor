//
//  File.swift
//  
//
//  Created by Morgan McColl on 25/11/20.
//

import GUUI
import Foundation

public protocol BoundedSize: Rigidable {
    
    var minWidth: CGFloat { get }
    
    var maxWidth: CGFloat { get }
    
    var minHeight: CGFloat { get }
    
    var maxHeight: CGFloat { get }
    
}
