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

struct TransitionView: View {
    
    @ObservedObject var viewModel: TransitionViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Path { path in
            path.move(to: viewModel.point0)
            path.addCurve(to: viewModel.point3, control1: viewModel.point1, control2: viewModel.point2)
            path.addLine(to: viewModel.arrowPoint0)
            path.addLine(to: viewModel.arrowPoint1)
            path.addLine(to: viewModel.point3)
        }
        .fill(config.borderColour)
        .overlay(
            ZStack {
                Circle()
                    .frame(width: viewModel.pointDiameter, height: viewModel.pointDiameter)
                    .background(Color.red)
                    .position(viewModel.point1)
                Circle()
                    .frame(width: viewModel.pointDiameter, height: viewModel.pointDiameter)
                    .background(Color.blue)
                    .position(viewModel.point2)
                ExpressionView(
                    machine: viewModel.$machine,
                    path: viewModel.path.condition.wrappedValue,
                    label: viewModel.condition,
                    language: .swift
                )
                    .position(viewModel.conditionPosition)
                if viewModel.priority != 0 {
                    ForEach(Array(stride(from: 1, to: viewModel.priority, by: 1)), id: \.self) { (strokeNumber) -> AnyView in
                        let strokePoints = viewModel.strokePoints(transition: strokeNumber)
                        return AnyView(Path { strokePath in
                            strokePath.move(to: strokePoints.0)
                            strokePath.addLine(to: strokePoints.1)
                        })
                    }
                }
            }
        )
    }
}
