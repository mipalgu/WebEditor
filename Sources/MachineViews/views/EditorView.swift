//
//  EditorView.swift
//  
//
//  Created by Morgan McColl on 20/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

public struct EditorView: View {
    
    @ObservedObject var viewModel: EditorViewModel
    
    var machineViewModel: MachineViewModel {
        viewModel.machine
    }
    
    var width: CGFloat
    
    var height: CGFloat
    
    @EnvironmentObject var config: Config
    
    public init(viewModel: EditorViewModel, width: CGFloat, height: CGFloat) {
        self.viewModel = viewModel
        self.width = width
        self.height = height
    }
    
    public var body: some View {
        ZStack {
            MainViewWithPanel(viewModel: viewModel, width: width, height: height)
                .frame(width: width, height: height)
                .coordinateSpace(name: "MAIN_VIEW")
                .position(x: width / 2.0, y: height / 2.0)
            DialogueView(viewModel: viewModel)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 20.0)
                        .background(config.backgroundColor)
                        .foregroundColor(config.backgroundColor)
                        .border(config.borderColour, width: 3.0)
                        .shadow(color: config.shadowColour, radius: 10, x: 0, y: 10)
                )
                .frame(minWidth: 400.0, maxWidth: 1000.0)
        }
    }
}
