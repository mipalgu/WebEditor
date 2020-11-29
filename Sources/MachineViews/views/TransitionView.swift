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
    
    @EnvironmentObject var config: Config
    
    var parentWidth: CGFloat
    
    var parentHeight: CGFloat
    
    var body: some View {
        Path { path in
            path.move(to: viewModel.point0)
            path.addCurve(to: viewModel.point3, control1: viewModel.point1, control2: viewModel.point2)
            path.addLine(to: viewModel.arrowPoint0)
            path.addLine(to: viewModel.arrowPoint1)
            path.addLine(to: viewModel.point3)
        }
        .fill(config.borderColour)
        .foregroundColor(config.borderColour)
        .overlay(
            ZStack {
                Circle()
                    .frame(width: viewModel.point1ViewModel.width, height: viewModel.point1ViewModel.height)
                    .background(Color.red)
                    .coordinateSpace(name: "MAIN_VIEW")
                    .position(viewModel.point1)
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("MAIN_VIEW"))
                        .onChanged({
                            viewModel.point1ViewModel.handleDrag(gesture: $0, frameWidth: parentWidth, frameHeight: parentHeight)
                        })
                        .onEnded({
                            viewModel.point1ViewModel.finishDrag(gesture: $0, frameWidth: parentWidth, frameHeight: parentHeight)
                        })
                    )
                Circle()
                    .frame(width: viewModel.point2ViewModel.width, height: viewModel.point2ViewModel.height)
                    .background(Color.blue)
                    .coordinateSpace(name: "MAIN_VIEW")
                    .position(viewModel.point2)
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("MAIN_VIEW"))
                        .onChanged({
                            viewModel.point2ViewModel.handleDrag(gesture: $0, frameWidth: parentWidth, frameHeight: parentHeight)
                        })
                        .onEnded({
                            viewModel.point2ViewModel.finishDrag(gesture: $0, frameWidth: parentWidth, frameHeight: parentHeight)
                        })
                    )
                ExpressionView(
                    value: viewModel.$machine[bindingTo: viewModel.path.condition.wrappedValue],
                    label: viewModel.condition,
                    language: .swift
                )
                    .multilineTextAlignment(.center)
                    .coordinateSpace(name: "MAIN_VIEW")
                    .position(viewModel.conditionPosition)
                    .fixedSize()
                if viewModel.priority != 0 {
                    ForEach(Array(stride(from: 1, to: viewModel.priority, by: 1)), id: \.self) { (strokeNumber) -> AnyView in
                        let strokePoints = viewModel.strokePoints(transition: strokeNumber)
                        return AnyView(Path { strokePath in
                            strokePath.move(to: strokePoints.0)
                            strokePath.addLine(to: strokePoints.1)
                        }.coordinateSpace(name: "MAIN_VIEW"))
                    }
                }
            }
        )
    }
}
