//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 24/4/21.
//

import TokamakShim
import Attributes
import Utilities
import Machines

struct MachineView: View {
    
    @ObservedObject var viewModel: MachineViewModel
    
    @State var attributesCollapsed: Bool = false

    var body: some View {
        HStack {
            CanvasView(viewModel: viewModel.canvasViewModel, focus: $viewModel.focus)
            VStack {
                if !attributesCollapsed {
                    AttributesPaneView(viewModel: viewModel.attributesPaneViewModel)
                        .frame(maxWidth: 500).animation(.none)
                }
            }.transition(.move(edge: .leading)).animation(.interactiveSpring())
        }.toolbar {
            ToolbarItem {
                HoverButton(action: {
                    attributesCollapsed.toggle()
                }, label: {
                    Image(systemName: "sidebar.squares.trailing").font(.system(size: 16, weight: .regular))
                })
            }
        }
    }
}


//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
