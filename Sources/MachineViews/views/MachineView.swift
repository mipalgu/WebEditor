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

struct MachineView<Sidebar: View>: View {
    
    @ObservedObject var viewModel: MachineViewModel
    
    let sideBar: () -> Sidebar
    
    @State var sideBarCollapsed: Bool = false
    @State var attributesCollapsed: Bool = false

    var body: some View {
        VStack {
            HStack {
                HStack {
                    HoverButton(action: {
                        sideBarCollapsed.toggle()
                    }, label: {
                        Image(systemName: "sidebar.leading").font(.system(size: 16, weight: .regular))
                    })
                    Spacer()
                }
                HStack {
                    Spacer()
                }
                HStack {
                    Spacer()
                    HoverButton(action: {
                        attributesCollapsed.toggle()
                    }, label: {
                        Image(systemName: "sidebar.squares.trailing").font(.system(size: 16, weight: .regular))
                    })
                }
            }.padding(.horizontal, 5).padding(.top, 5)
            Divider()
            HStack {
                VStack {
                    if !sideBarCollapsed {
                        sideBar()
                    }
                }.transition(.move(edge: .leading)).animation(.interactiveSpring())
                CanvasView(viewModel: viewModel.canvasViewModel, focus: $viewModel.focus)
                VStack {
                    if !attributesCollapsed {
                        AttributesPaneView(viewModel: viewModel.attributesPaneViewModel)
                            .frame(maxWidth: 500).animation(.none)
                    }
                }.transition(.move(edge: .leading)).animation(.interactiveSpring())
            }
        }
    }
}


//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
