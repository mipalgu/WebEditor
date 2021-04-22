//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/4/21.
//

import Foundation

public struct FocusedObjects {
    
    public var principle: ViewType = .machine
    
    public var selected: Set<ViewType> = []
    
    public init() {
        self.principle = .machine
        self.selected = []
    }
    
    public init(principle: ViewType) {
        self.principle = principle
        self.selected = [principle]
    }
    
    public init(selected: Set<ViewType>) {
        self.principle = .machine
        self.selected = selected
    }
    
}
