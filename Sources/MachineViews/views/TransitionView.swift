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
            path.addCurve(to: viewModel.point3, control1: viewModel.point2, control2: viewModel.point1)
        }.overlay(
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
            }
        )
    }
}
