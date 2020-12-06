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
    
    @Binding var strokeNumber: UInt8
    
    @Binding var focused: Bool
    
    var arrowPoint0: CGPoint {
        let theta = atan2(Double(point3.y - point2.y), Double(point3.x - point2.x)) +  Double.pi - Double.pi / 6.0
        let y = point3.y + CGFloat(10.0 * sin(theta))
        let x = point3.x + CGFloat(10.0 * cos(theta))
        return CGPoint(x: x, y: y)
    }
    
    var arrowPoint1: CGPoint {
        let theta = atan2(Double(point3.y - point2.y), Double(point3.x - point2.x)) + Double.pi + Double.pi / 6.0
        let y = point3.y + CGFloat(10.0 * sin(theta))
        let x = point3.x + CGFloat(10.0 * cos(theta))
        return CGPoint(x: x, y: y)
    }
    
    var strokeTheta: Double {
        atan2(Double(point1.y - point0.y), Double(point1.x - point0.x))
    }
    
    func getStrokeCenter(number: UInt8) -> CGPoint {
        let offset = 2.0 + 2.0 * Double(number)
        return CGPoint(x: point0.x + CGFloat(offset * cos(strokeTheta)), y: point0.y + CGFloat(offset * sin(strokeTheta)))
    }
    
    func strokePoint0(number: UInt8) -> CGPoint {
        let center = getStrokeCenter(number: number)
        let point1Theta = strokeTheta + Double.pi / 2.0
        let length = 2.0 * Double(number)
        return CGPoint(x: center.x + CGFloat(length * cos(point1Theta)), y: center.y + CGFloat(length * sin(point1Theta)))
    }
    
    func strokePoint1(number: UInt8) -> CGPoint {
        let center = getStrokeCenter(number: number)
        let point1Theta = strokeTheta - Double.pi / 2.0
        let length = 2.0 * Double(number)
        return CGPoint(x: center.x + CGFloat(length * cos(point1Theta)), y: center.y + CGFloat(length * sin(point1Theta)))
    }
    
    @EnvironmentObject public var config: Config
    
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: point0)
                path.addCurve(to: point3, control1: point1, control2: point2)
                path.move(to: point3)
                path.addLine(to: arrowPoint0)
                path.move(to: point3)
                path.addLine(to: arrowPoint1)
            }
            .stroke(config.textColor, lineWidth: 2)
            .coordinateSpace(name: "MAIN_VIEW")
            .foregroundColor(config.textColor)
            if strokeNumber > 0 {
                ForEach(1...strokeNumber, id: \.self) { number in
                    Path { strokePath in
                        strokePath.move(to: strokePoint0(number: number))
                        strokePath.addLine(to: strokePoint1(number: number))
                    }
                    .stroke(config.textColor, lineWidth: 2)
                    .coordinateSpace(name: "MAIN_VIEW")
                }
            }
            if focused {
                Circle()
                    .position(point0)
                    .frame(width: 20, height: 20)
                    .gesture(DragGesture().onChanged {
                        point0 = $0.location
                    }.onEnded {
                        point0 = $0.location
                    })
                Circle()
                    .position(point1)
                    .background(Color.red)
                    .frame(width: 20, height: 20)
                    .gesture(DragGesture().onChanged {
                        point1 = $0.location
                    }.onEnded {
                        point1 = $0.location
                    })
                Circle()
                    .position(point2)
                    .background(Color.blue)
                    .frame(width: 20, height: 20)
                    .gesture(DragGesture().onChanged {
                        point2 = $0.location
                    }.onEnded {
                        point2 = $0.location
                    })
                Circle()
                    .position(point3)
                    .frame(width: 20, height: 20)
                    .gesture(DragGesture().onChanged {
                        point3 = $0.location
                    }.onEnded {
                        point3 = $0.location
                    })
            }
        }
    }
}
