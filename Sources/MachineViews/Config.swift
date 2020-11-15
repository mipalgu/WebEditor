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

public class Config: ObservableObject {
    
    #if canImport(TokamakShim)
    @Published public var textColor = Color.black
    #elseif canImport(AppKit)
    @Published public var textColor = Color(NSColor.controlTextColor)
    #elseif canImport(UIKit)
    @Published public var textColor = Color(UIColor.label)
    #else
    @Published public var textColor = Color.black
    #endif
    
    #if canImport(TokamakShim)
    @Published public var backgroundColor = Color.white
    #elseif canImport(AppKit)
    @Published public var backgroundColor = Color(NSColor.controlBackgroundColor)
    #elseif canImport(UIKit)
    @Published public var backgroundColor = Color(UIColor.secondarySystemBackground)
    #else
    @Published public var backgroundColor = Color.clear
    #endif
    
    @Published public var fieldColor = Color.black.opacity(0.2)
    
    @Published public var width: Double = 1280
    
    @Published public var height: Double = 720
    
    #if canImport(TokamakShim)
    @Published public var stateColour = Color.white
    #elseif canImport(AppKit)
    @Published public var stateColour = Color(NSColor.controlBackgroundColor)
    #elseif canImport(UIKit)
    @Published public var stateColour = Color(UIColor.label)
    #else
    @Published public var stateColour = Color.white
    #endif
    
    #if canImport(TokamakShim)
    @Published public var borderColour = Color.white
    #elseif canImport(AppKit)
    @Published public var borderColour = Color(NSColor.separatorColor)
    #elseif canImport(UIKit)
    @Published public var borderColour = Color(UIColor.opaqueSeparator)
    #else
    @Published public var borderColour = Color.white
    #endif
    
    public init() {}
    
}
