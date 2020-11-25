//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 26/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

struct ArrowView: View {
    
    @Binding var pointOffScreen: CGPoint
    
    @Binding var label: String
    
    @Binding var frameWidth: CGFloat
    
    @Binding var frameHeight: CGFloat
    
    @EnvironmentObject var config: Config
    
    var point0: CGPoint {
        let x = pointOffScreen.x < 0 ? 0 : frameWidth
        let y = pointOffScreen.y < 0 ? 0 : frameHeight
        return CGPoint(x: x, y: y)
    }
    
    var point1: CGPoint {
        let x = pointOffScreen.x < 0 ? 50.0 : frameWidth - 50.0
        let y = pointOffScreen.y < 0 ? 50.0 : frameHeight - 50.0
        return CGPoint(x: x, y: y)
    }
    
    var dx: CGFloat {
        point1.x - point0.x
    }
    
    var dy: CGFloat {
        point1.y - point0.y
    }
    
    var theta: Double {
        if dx == 0 {
            return Double.pi / 2.0
        }
        return atan2(Double(dy), Double(dx))
    }
    
    var arrow1: CGPoint {
        let angle = theta + Double.pi - Double.pi / 4.0
        let x = CGFloat(5.0 * cos(angle))
        let y = CGFloat(5.0 * sin(angle))
        return CGPoint(x: point1.x + x, y: point1.y + y)
    }
    
    var arrow2: CGPoint {
        let angle = theta - Double.pi + Double.pi / 4.0
        let x = CGFloat(5.0 * cos(angle))
        let y = CGFloat(5.0 * sin(angle))
        return CGPoint(x: point1.x + x, y: point1.y + y)
    }
    
    var center: CGPoint {
        CGPoint(x: point0.x + dx / 2.0, y: point0.y + dy / 2.0)
    }
    
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: point0)
                path.addLine(to: point1)
                path.addLine(to: arrow1)
                path.move(to: point1)
                path.addLine(to: arrow2)
            }
            .coordinateSpace(name: "MAIN_VIEW")
            Text(label)
                .font(config.fontBody)
                .coordinateSpace(name: "MAIN_VIEW")
                .position(center)
        }
    }
}
