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
                editing: $focused,
                color: focused ? config.highlightColour : config.textColor
            )
            if focused {
                AnchorPoint()
                    .position(point0)
                    .gesture(DragGesture().onChanged {
                        self.point0 = $0.location
                    }.onEnded {
                        point0 = $0.location
                    })
                AnchorPoint(color: .red)
                    .position(point1)
                    .gesture(DragGesture().onChanged {
                        point1 = $0.location
                    }.onEnded {
                        point1 = $0.location
                    })
                AnchorPoint(color: .blue)
                    .position(point2)
                    .gesture(DragGesture().onChanged {
                        point2 = $0.location
                    }.onEnded {
                        point2 = $0.location
                    })
                AnchorPoint()
                    .position(point3)
                    .gesture(DragGesture().onChanged {
                        point3 = $0.location
                    }.onEnded {
                        point3 = $0.location
                    })
            }
        }
    }
}

struct TransitionView_Previews: PreviewProvider {
    
    struct Focused_Preview: View {
        
        @State var point0: CGPoint = CGPoint(x: 50, y: 50)
        @State var point1: CGPoint = CGPoint(x: 100, y: 100)
        @State var point2: CGPoint = CGPoint(x: 150, y: 100)
        @State var point3: CGPoint = CGPoint(x: 150, y: 50)
        @State var strokeNumber: UInt8 = 2
        @State var label: String = "true"
        @State var focused: Bool = true
        
        let config = Config()
        
        var body: some View {
            TransitionView(
                point0: $point0,
                point1: $point1,
                point2: $point2,
                point3: $point3,
                strokeNumber: $strokeNumber,
                label: $label,
                focused: $focused
            ).environmentObject(config)
        }
        
    }
    
    struct Unfocused_Preview: View {
        
        @State var point0: CGPoint = CGPoint(x: 50, y: 50)
        @State var point1: CGPoint = CGPoint(x: 100, y: 100)
        @State var point2: CGPoint = CGPoint(x: 150, y: 100)
        @State var point3: CGPoint = CGPoint(x: 150, y: 50)
        @State var strokeNumber: UInt8 = 2
        @State var label: String = "true"
        @State var focused: Bool = false
        
        let config = Config()
        
        var body: some View {
            TransitionView(
                point0: $point0,
                point1: $point1,
                point2: $point2,
                point3: $point3,
                strokeNumber: $strokeNumber,
                label: $label,
                focused: $focused
            ).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Focused_Preview()
            Unfocused_Preview()
        }
    }
}
