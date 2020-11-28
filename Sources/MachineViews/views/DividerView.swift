//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 28/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

struct DividerView: View {
    
    @ObservedObject var viewModel: BoundedPositionViewModel
    
    var parentWidth: CGFloat
    
    var parentHeight: CGFloat
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Divider()
            .frame(width: viewModel.width, height: viewModel.height)
            .background(config.borderColour)
            .opacity(1)
            .gesture(DragGesture(minimumDistance: 0.0)
                .onChanged({ viewModel.handleDrag(gesture: $0, frameWidth: parentWidth, frameHeight: parentHeight)})
                .onEnded({ viewModel.finishDrag(gesture: $0, frameWidth: parentWidth, frameHeight: parentHeight) })
            )
    }
}
