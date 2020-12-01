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
    
    @Binding var showArrangement: Bool
    
    @EnvironmentObject public var config: Config
    
    func getMachine(_ index: Int) -> EditorViewModel {
        viewModel.allMachines[index]
    }
    
    
    public init(viewModel: ArrangementViewModel, showArrangement: Binding<Bool>) {
        self.viewModel = viewModel
        self._showArrangement = showArrangement
    }
    
    public var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ForEach(Array(viewModel.allMachines.indices), id: \.self) { index in
                Text(getMachine(index).machine.name)
                    .font(config.fontTitle2)
                    .coordinateSpace(name: "MAIN_VIEW")
                    .position(getMachine(index).machine.getLocation(width: geometry.size.width, height: geometry.size.height))
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .background(config.stateColour)
                            .foregroundColor(getMachine(index) === viewModel.currentMachine ? config.highlightColour : config.borderColour)
                    )
                    .frame(width: getMachine(index).machine.width, height: getMachine(index).machine.height)
                    .onTapGesture(count: 1) {
                        viewModel.currentMachineIndex = index
                    }
                    .onTapGesture(count: 2) {
                        viewModel.currentMachineIndex = index
                        showArrangement = false
                    }
                    .gesture(DragGesture().onChanged {
                        getMachine(index).machine.handleDrag(
                            gesture: $0,
                            frameWidth: geometry.size.width,
                            frameHeight: geometry.size.height
                        )
                    }.onEnded {
                        getMachine(index).machine.finishDrag(
                            gesture: $0,
                            frameWidth: geometry.size.width,
                            frameHeight: geometry.size.height
                        )
                    })
            }
            .frame(minWidth: 1280, minHeight: 720)
        }
    }
}

