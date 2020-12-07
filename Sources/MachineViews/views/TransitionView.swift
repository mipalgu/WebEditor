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
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        ArrowWithLabelView(
            point0: viewModel.point0Binding,
            point1: viewModel.point1Binding,
            point2: viewModel.point2Binding,
            point3: viewModel.point3Binding,
            strokeNumber: viewModel.priorityBinding,
            label: viewModel.conditionBinding,
            focused: $focused,
            colour: focused ? config.highlightColour : config.textColor
        )
        .coordinateSpace(name: "MAIN_VIEW")
    }
}
