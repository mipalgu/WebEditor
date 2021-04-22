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
import Machines
import Attributes
import AttributeViews

public final class Config: ObservableObject, AttributeViewConfig {
    
    #if canImport(TokamakShim)
    @Published public var textColor = Color.black
    #elseif canImport(AppKit)
    @Published public var textColor = Color(NSColor.controlTextColor)
    #elseif canImport(UIKit)
    @Published public var textColor = Color(UIColor.secondaryLabel)
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
    
    @Published public var width: CGFloat = 300
    
    @Published public var height: CGFloat = 200
    
    #if canImport(TokamakShim)
    @Published public var stateColour = Color.white
    #elseif canImport(AppKit)
    @Published public var stateColour = Color(NSColor.windowBackgroundColor)
    #elseif canImport(UIKit)
    @Published public var stateColour = Color(UIColor.systemBackground)
    #else
    @Published public var stateColour = Color.white
    #endif
    
    #if canImport(TokamakShim)
    @Published public var stateTextColour = Color.black
    #elseif canImport(AppKit)
    @Published public var stateTextColour = Color(NSColor.labelColor)
    #elseif canImport(UIKit)
    @Published public var stateTextColour = Color(UIColor.label)
    #else
    @Published public var stateTextColour = Color.black
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
    
    #if canImport(TokamakShim)
    @Published public var shadowColour = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5)
    #elseif canImport(AppKit)
    @Published public var shadowColour = Color(NSColor.shadowColor)
    #elseif canImport(UIKit)
    @Published public var shadowColour = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5)
    #else
    @Published public var shadowColour = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5)
    #endif
    
    #if canImport(TokamakShim)
    @Published public var highlightColour = Color.blue
    #elseif canImport(AppKit)
    @Published public var highlightColour = Color(NSColor.selectedContentBackgroundColor)
    #elseif canImport(UIKit)
    @Published public var highlightColour = Color(UIColor.tertiarySystemBackground)
    #else
    @Published public var highlightColour = Color.blue
    #endif
    @Published public var fontTitle1: Font = Font.system(size: 32.0)
    @Published public var fontTitle2: Font = Font.system(size: 24.0)
    @Published public var fontTitle3: Font = Font.system(size: 20.0)
    @Published public var fontHeading: Font = Font.system(size: 16.0)
    @Published public var fontBody: Font = Font.system(size: 12.0)
    
    @Published public var rightPaneStartPoint: CGFloat = 200.0
    
    @Published public var alertView: DialogType = .none
    
    @Published public var focusedObjects: FocusedObjects = FocusedObjects()
    
    public init() {}
    
}
