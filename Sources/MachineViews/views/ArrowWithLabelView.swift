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
    
    var point0: CGPoint
    
    var point1: CGPoint
    
    var point2: CGPoint
    
    var point3: CGPoint
    
    var strokeNumber: UInt8
    
    var label: String
    
    var colour: Color
    
    @EnvironmentObject public var config: Config
    
    var center: CGPoint {
        let dx = (point2.x - point1.x) / 2.0
        let dy = (point2.y - point1.y) / 2.0
        return CGPoint(x: point1.x + dx, y: point1.y + dy)
    }
    
    var body: some View {
        ZStack {
            ArrowView(point0: point0, point1: point1, point2: point2, point3: point3, strokeNumber: strokeNumber, colour: colour)
                .coordinateSpace(name: "MAIN_VIEW")
            Text(label)
                .coordinateSpace(name: "MAIN_VIEW")
                .font(config.fontBody)
                .position(center)
        }
        .coordinateSpace(name: "MAIN_VIEW")
    }
}
