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
    
    @ObservedObject var viewModel: TransitionViewModel
    
    @Binding var focused: Bool
    
    var frameWidth: CGFloat
    
    var frameHeight: CGFloat
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        ZStack {
            ArrowWithLabelView(
                point0: viewModel.point0,
                point1: viewModel.point1,
                point2: viewModel.point2,
                point3: viewModel.point3,
                strokeNumber: viewModel.priority,
                label: viewModel.condition,
                colour: focused ? config.highlightColour : config.textColor
            )
            .coordinateSpace(name: "MAIN_VIEW")
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("MAIN_VIEW")).onChanged {
                viewModel.handleDrag(gesture: $0, frameWidth: frameWidth, frameHeight: frameHeight)
            }.onEnded {
                viewModel.finishDrag(gesture: $0, frameWidth: frameWidth, frameHeight: frameHeight)
            })
            if focused {
                Circle()
                    .coordinateSpace(name: "MAIN_VIEW")
                    .position(viewModel.point0)
                    .frame(width: 20, height: 20)
                    .gesture(DragGesture().onChanged {
                        viewModel.point0 = $0.location
                    }.onEnded {
                        viewModel.point0 = $0.location
                    })
                Circle()
                    .coordinateSpace(name: "MAIN_VIEW")
                    .position(viewModel.point1)
                    .background(Color.red)
                    .frame(width: 20, height: 20)
                    .gesture(DragGesture().onChanged {
                        viewModel.point1 = $0.location
                    }.onEnded {
                        viewModel.point1 = $0.location
                    })
                Circle()
                    .coordinateSpace(name: "MAIN_VIEW")
                    .position(viewModel.point2)
                    .background(Color.blue)
                    .frame(width: 20, height: 20)
                    .gesture(DragGesture().onChanged {
                        viewModel.point2 = $0.location
                    }.onEnded {
                        viewModel.point2 = $0.location
                    })
                Circle()
                    .coordinateSpace(name: "MAIN_VIEW")
                    .position(viewModel.point3)
                    .frame(width: 20, height: 20)
                    .gesture(DragGesture().onChanged {
                        viewModel.point3 = $0.location
                    }.onEnded {
                        viewModel.point3 = $0.location
                    })
            }
        }
    }
}
