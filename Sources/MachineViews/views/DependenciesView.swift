//
//  SwiftUIView.swift
//
//
//  Created by Morgan McColl on 23/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities

struct DependenciesView: View {
    
    @ObservedObject var viewModel: ArrangementViewModel
    
    @Binding var collapsed: Bool
    
    let collapseLeft: Bool
    let buttonSize: CGFloat
    let buttonWidth: CGFloat
    let buttonHeight: CGFloat
    
    let label = "Dependencies"
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        VStack {
            if !collapsed {
                HStack {
                    if !collapseLeft {
                        Button(action: { collapsed = true }) {
                            Image(systemName: "arrow.right.to.line.alt")
                                .font(.system(size: buttonSize, weight: .regular))
                                .frame(width: buttonWidth, height: buttonHeight)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    Spacer()
                    Text(label.capitalized)
                        .font(config.fontTitle3)
                        .padding(.horizontal, 10)
                        .padding(collapseLeft ? .leading : .trailing, buttonWidth / 2.0 + 10.0)
                    Spacer()
                    if collapseLeft {
                        
                        Button(action: { collapsed = true }) {
                            Image(systemName: "arrow.left.to.line.alt")
                                .font(.system(size: buttonSize, weight: .regular))
                                .frame(width: buttonWidth, height: buttonHeight)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                ForEach(viewModel.rootMachineViewModels.map { $0.machine.$machine }, id: \.self.value) {ref in
                    ForEach(Array(ref.value.dependencies.indices), id: \.self) {
                        DependencyView(
                            viewModel: viewModel,
                            machine: ref,
                            path: ref.value.path.dependencies[$0]
                        )
                        .background(viewModel.currentMachine.machine.$machine === ref ? config.highlightColour : Color.clear)
                    }
                }
                Spacer()
            } else {
                HStack {
                    if collapseLeft {
                            Spacer()
                            Button(action: { collapsed = false }) {
                                Image(systemName: "arrow.right.to.line.alt")
                                    .font(.system(size: buttonSize, weight: .regular))
                                    .frame(width: buttonWidth, height: buttonHeight)
                            }.buttonStyle(PlainButtonStyle())
                        
                    } else {
                        Button(action: { collapsed = false }) {
                            Image(systemName: "arrow.left.to.line.alt")
                                .font(.system(size: buttonSize, weight: .regular))
                                .frame(width: buttonWidth, height: buttonHeight)
                        }.buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                }
                .padding(.horizontal, 10)
                Spacer()
                if collapseLeft {
                    Text(label.capitalized)
                        .font(config.fontTitle2)
                        .rotationEffect(Angle(degrees: -90.0))
                        .frame(minWidth: 500, maxWidth: .infinity, maxHeight: 300)
                        .scaledToFit()
                } else {
                    Text(label.capitalized)
                        .font(config.fontTitle2)
                        .rotationEffect(Angle(degrees: 90.0))
                        .frame(minWidth: 500, maxWidth: .infinity, maxHeight: 300)
                        .scaledToFit()
                }
                Spacer()
            }
        }
    }
}
