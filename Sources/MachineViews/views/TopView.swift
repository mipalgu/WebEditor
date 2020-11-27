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

struct TopView: View {
    
    @ObservedObject var viewModel: ArrangementViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        VStack(alignment: .leading) {
            MenuView(viewModel: viewModel)
                .background(config.stateColour)
            HStack {
                CollapsableAttributeGroupsView(machine: <#T##Ref<Machine>#>, path: <#T##Path<Machine, [AttributeGroup]>#>, label: <#T##String#>, collapsed: <#T##Binding<Bool>#>, collapseLeft: <#T##Bool#>, buttonSize: <#T##CGFloat#>, buttonWidth: <#T##CGFloat#>, buttonHeight: <#T##CGFloat#>)
                DividerView(
                    viewModel: ,
                    parentWidth: reader.size.width,
                    parentHeight: reader.size.width
                )
                TabView {
                    ForEach(Array(viewModel.rootMachineViewModels.indices), id: \.self) { index in
                        ContentView(editorViewModel: viewModel.rootMachineViewModels[index])
                            .tabItem {
                                Text(viewModel.rootMachineViewModels[index].machine.name)
                            }.tag(index)
                    }
                }
            }
        }
    }
}

