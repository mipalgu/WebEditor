//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 17/4/21.
//

import SwiftUI

struct GridView: View {
    
    var width: CGFloat
    
    var height: CGFloat
    
    let gridHeight: CGFloat = 80.0
    
    let gridWidth: CGFloat = 80.0
    
    var coordinateSpace: String
    
    var backgroundColor: Color
    
    var foregroundColor: Color
    
    var body: some View {
        ZStack {
            HStack {
                ForEach(Array(stride(from: -width / 2.0 + gridWidth, to: width / 2.0, by: gridWidth)), id: \.self) {
                    Divider()
                        .coordinateSpace(name: coordinateSpace)
                        .position(x: $0, y: height / 2.0)
                        .frame(width: 2.0, height: height)
                        .foregroundColor(foregroundColor)
                }
            }
            VStack {
                ForEach(
                    Array(stride(from: -height / 2.0 + gridHeight, to: height / 2.0, by: gridHeight)),
                    id: \.self
                ) {
                    Divider()
                        .coordinateSpace(name: coordinateSpace)
                        .position(x: width / 2.0, y: $0)
                        .frame(width: width, height: 2.0)
                        .foregroundColor(foregroundColor)
                }
            }
        }
        .background(
            backgroundColor
//                    .onTapGesture(count: 2) {
//                        viewModel.newState()
//                    }
//                    .onTapGesture(count: 1) {
//                        viewModel.removeHighlights()
//                        editorViewModel.changeFocus()
//                    }
//                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("MAIN_VIEW"))
//                        .onChanged {
//                            self.viewModel.moveElements(gesture: $0, frameWidth: geometry.size.width, frameHeight: geometry.size.height)
//                        }.onEnded {
//                            self.viewModel.finishMoveElements(gesture: $0, frameWidth: geometry.size.width, frameHeight: geometry.size.height)
//                        }
//                    )
        )
        .clipped()
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
