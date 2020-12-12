//
//  File.swift
//  
//
//  Created by Morgan McColl on 12/12/20.
//

#if canImport(SwiftUI) && !canImport(TokamakShim)

import SwiftUI

public struct KeyEventHandling: NSViewRepresentable {
    
    var keyDownCallback: (NSEvent) -> Void
    
    var keyUpCallback: (NSEvent) -> Void
    
    class KeyView: NSView {
        
        var keyDownCallback: (NSEvent) -> Void
        
        var keyUpCallback: (NSEvent) -> Void
        
        override var acceptsFirstResponder: Bool { true }
        
        override func keyDown(with event: NSEvent) {
            super.keyDown(with: event)
            self.keyDownCallback(event)
        }
        
        override func keyUp(with event: NSEvent) {
            super.keyUp(with: event)
            self.keyUpCallback(event)
        }
        
        init(keyDown: @escaping (NSEvent) -> Void, keyUp: @escaping (NSEvent) -> Void) {
            self.keyDownCallback = keyDown
            self.keyUpCallback = keyUp
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    public init(keyDownCallback: @escaping (NSEvent) -> Void, keyUpCallback: @escaping (NSEvent) -> Void) {
        self.keyDownCallback = keyDownCallback
        self.keyUpCallback = keyUpCallback
    }
    
    public func makeNSView(context: Context) -> some NSView {
        let view = KeyView(keyDown: keyDownCallback, keyUp: keyUpCallback)
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }
    
    public func updateNSView(_ nsView: NSViewType, context: Context) {
        
    }
    
}

#endif
