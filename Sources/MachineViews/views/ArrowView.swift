//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 2/12/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Utilities

struct ArrowView: View {
    
    @Binding var point0: CGPoint
    
    @Binding var point1: CGPoint
    
    @Binding var point2: CGPoint
    
    @Binding var point3: CGPoint
    
    @EnvironmentObject public var config: Config
    
    var body: some View {
        Path { path in
            path.move(to: point0)
            path.addCurve(to: point3, control1: point1, control2: point2)
        }.foregroundColor(config.borderColour)
    }
}
