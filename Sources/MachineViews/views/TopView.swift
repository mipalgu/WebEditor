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

import Machines

public struct TopView: View {
    
    @ObservedObject var viewModel: ArrangementViewModel
    
    @EnvironmentObject var config: Config
    
    public init(viewModel: ArrangementViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            MenuView(viewModel: viewModel)
                .background(config.stateColour)
            HStack {
                GeometryReader { (geometry: GeometryProxy) in
                    ScrollView {
                        if viewModel.leftPaneCollapsed {
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        viewModel.leftPaneCollapsed = false
                                        viewModel.leftDivider.location = CGPoint(x: viewModel.leftPaneMinWidth + viewModel.dividerWidth / 2.0, y: geometry.size.height / 2.0)
                                    }) {
                                        Image(systemName: "arrow.right.to.line.alt")
                                            .font(.system(size: 20, weight: .regular))
                                            .frame(width: 30, height: 30)
                                    }.buttonStyle(PlainButtonStyle())
                                }
                                Spacer()
                                Text("Dependencies")
                                    .font(config.fontTitle2)
                                    .rotationEffect(Angle(degrees: -90.0))
                                    .fixedSize()
                                    .position(CGPoint(x: viewModel.leftPaneWidth / 2.0, y: geometry.size.height / 2.0))
                            }
                        } else {
                            VStack {
                                HStack {
                                    Text("Dependencies")
                                        .font(config.fontTitle2)
                                        .padding(.leading, 10)
                                    Spacer()
                                    Button(action: {
                                        viewModel.leftPaneCollapsed = true
                                        viewModel.leftDivider.location = CGPoint(x:viewModel.collapsedPaneWidth + viewModel.dividerWidth / 2.0, y: geometry.size.height / 2.0)
                                    }) {
                                        Image(systemName: "arrow.left.to.line.alt")
                                            .font(.system(size: 20, weight: .regular))
                                            .frame(width: 30, height: 30)
                                    }.buttonStyle(PlainButtonStyle())
                                }
                                ForEach(viewModel.focusedView.machine.machine.dependencies, id: \.self) { (dep: MachineDependency) in
                                    Text(dep.name)
                                        .padding(10)
                                        .frame(width: viewModel.leftPaneWidth)
                                        .background(viewModel.focusedView.machine.name == dep.name ? config.highlightColour : Color.clear)
                                        .cornerRadius(5)
                                        .font(config.fontTitle3)
                                        .onTapGesture {
                                            
                                        }
                                }
                                Spacer()
                            }
                        }
                    }
                    .frame(width: viewModel.leftPaneWidth, height: geometry.size.height)
                    .position(CGPoint(x: viewModel.leftPaneWidth / 2.0, y: geometry.size.height / 2.0))
                    DividerView(
                        viewModel: viewModel.leftDivider,
                        parentWidth: geometry.size.width,
                        parentHeight: geometry.size.height
                    )
                    .position(viewModel.dividerLocation)
                    TabView {
                        ForEach(Array(viewModel.rootMachineViewModels.indices), id: \.self) { index in
                            EditorView(viewModel: viewModel.rootMachineViewModels[index])
                                .tabItem {
                                    Text(viewModel.rootMachineViewModels[index].machine.name)
                                }.tag(index)
                        }
                    }
                    .frame(maxWidth: geometry.size.width - viewModel.leftPaneWidth - viewModel.dividerWidth)
                    .position(viewModel.rightPaneAndViewLocation(width: geometry.size.width, height: geometry.size.height))
                }
            }
        }
    }
}

