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
    
    @Binding var focused: Bool
    
    @EnvironmentObject public var config: Config
    
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: point0)
                path.addCurve(to: point3, control1: point1, control2: point2)
            }.foregroundColor(config.borderColour)
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
