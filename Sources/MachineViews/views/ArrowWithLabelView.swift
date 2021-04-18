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

struct ArrowWithLabelView: View {
    
    @Binding var point0: CGPoint
    
    @Binding var point1: CGPoint
    
    @Binding var point2: CGPoint
    
    @Binding var point3: CGPoint
    
    @Binding var strokeNumber: UInt8
    
    @Binding var label: String
    
    var color: Color
    
    @EnvironmentObject public var config: Config
    
    var center: CGPoint {
        let dx = (point2.x - point1.x) / 2.0
        let dy = (point2.y - point1.y) / 2.0
        return CGPoint(x: point1.x + dx, y: point1.y + dy)
    }
    
    var body: some View {
        ZStack {
            ArrowView(point0: $point0, point1: $point1, point2: $point2, point3: $point3, strokeNumber: $strokeNumber, colour: color)
            TextField("", text: $label)
                .font(config.fontBody)
                .fixedSize()
                .position(center)
        }
    }
}
