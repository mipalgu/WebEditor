//
//  StateCollapsedview.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct StateCollapsedView: View {
    
    @ObservedObject var viewModel: StateViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                Ellipse()
                    .strokeBorder(config.borderColour, lineWidth: 2.0, antialiased: true)
                    .background(Ellipse().foregroundColor(config.stateColour))
                    .padding(.bottom, 2)
                    .frame(width: viewModel.collapsedWidth, height: viewModel.collapsedHeight)
                    .clipped()
                Text(viewModel.name)
                    .font(.title2)
                    .foregroundColor(config.textColor)
                    .frame(maxWidth: viewModel.collapsedWidth, maxHeight: viewModel.collapsedHeight)
                    .clipped()
            }
        }
        
    }
}
