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

import Machines
import Attributes
import Utilities

public struct ArrangementView: View {
    
    @ObservedObject public var viewModel: ArrangementViewModel
    
    @EnvironmentObject public var config: Config
    
    public init(viewModel: ArrangementViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ForEach(viewModel.allMachines, id: \.self) {
                Text($0.machine.name)
                    .font(config.fontTitle2)
                    .coordinateSpace(name: "MAIN_VIEW")
                    .position($0.machine.getLocation(width: geometry.size.width, height: geometry.size.height))
                    .background(RoundedRectangle(cornerRadius: 20).background(config.stateColour))
                    .frame(width: $0.machine.width, height: $0.machine.height)
            }
            .frame(minWidth: 1280, minHeight: 720)
        }
    }
}

