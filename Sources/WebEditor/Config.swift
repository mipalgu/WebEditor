//
//  Config.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

class Config: ObservableObject {
    
    @Published public var textColor = Color.black
    
    @Published public var backgroundColor = Color.white
    
    @Published public var fieldColor = Color.black.opacity(0.2)
    
}
