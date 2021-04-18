//
//  TransitionView.swift
//  
//
//  Created by Morgan McColl on 16/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities
import AttributeViews

struct TransitionView: View {
    
    @Binding var point0: CGPoint
    
    @Binding var point1: CGPoint
    
    @Binding var point2: CGPoint
    
    @Binding var point3: CGPoint
    
    @Binding var strokeNumber: UInt8
    
    @Binding var label: String
    
    @Binding var focused: Bool
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        ZStack {
            ArrowWithLabelView(
                point0: $point0,
                point1: $point1,
                point2: $point2,
                point3: $point3,
                strokeNumber: $strokeNumber,
                label: $label,
                color: focused ? config.highlightColour : config.textColor
            )
            if focused {
                Circle()
                    .position(point0)
                    .frame(width: 20, height: 20)
                    .gesture(DragGesture().onChanged {
                        self.point0 = $0.location
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
