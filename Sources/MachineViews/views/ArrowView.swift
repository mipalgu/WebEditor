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
    
    var frameWidth: CGFloat
    
    var frameHeight: CGFloat
    
    @EnvironmentObject var config: Config
    
    var point0: CGPoint {
        var x: CGFloat = pointOffScreen.x
        if pointOffScreen.x < 0 {
            x = 0
        } else if pointOffScreen.x > frameWidth {
            x = frameWidth
        }
        var y: CGFloat = pointOffScreen.y
        if pointOffScreen.y < 0 {
            y = 0.0
        } else if pointOffScreen.y > frameHeight {
            y = frameHeight
        }
        return CGPoint(x: x, y: y)
    }
    
    var point1: CGPoint {
        var x: CGFloat = pointOffScreen.x
        if pointOffScreen.x < 0 {
            x = 30.0
        } else if pointOffScreen.x > frameWidth {
            x = frameWidth - 30.0
        }
        var y: CGFloat = pointOffScreen.y
        if pointOffScreen.y < 0 {
            y = 30.0
        } else if pointOffScreen.y > frameHeight {
            y = frameHeight - 30.0
        }
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
        let x = CGFloat(15.0 * cos(angle))
        let y = CGFloat(15.0 * sin(angle))
        return CGPoint(x: point1.x + x, y: point1.y + y)
    }
    
    var arrow2: CGPoint {
        let angle = theta - Double.pi + Double.pi / 4.0
        let x = CGFloat(15.0 * cos(angle))
        let y = CGFloat(15.0 * sin(angle))
        return CGPoint(x: point1.x + x, y: point1.y + y)
    }
    
    var center: CGPoint {
        CGPoint(x: point0.x + dx / 2.0, y: point0.y + dy / 2.0)
    }
    
    var body: some View {
        /*ZStack {
            Path { path in
                path.move(to: point0)
                path.addLine(to: point1)
                path.addLine(to: arrow1)
                path.move(to: point1)
                path.addLine(to: arrow2)
            }.fill(Color.clear)
            .coordinateSpace(name: "MAIN_VIEW")*/
            Text(label)
                .font(config.fontBody)
                .coordinateSpace(name: "MAIN_VIEW")
                .position(center)
        //}
    }
}
