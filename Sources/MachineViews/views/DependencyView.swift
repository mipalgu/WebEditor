//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 30/11/20.
//

import TokamakShim

import Machines
import Attributes
import Utilities

struct DependencyView: View {
    
    let dependency: MachineDependency
    
    @ObservedObject var viewModel: DependencyViewModel
    
    @Binding var focus: URL
    
    let padding: CGFloat
    
    let parents: Set<URL>
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        VStack {
            HStack {
                Group {
                    if let machineViewModel = viewModel.viewModel, machineViewModel.machine.dependencies.isEmpty {
                        Text(dependency.name)
                            .foregroundColor(config.textColor)
                            .padding(.leading, 25)
                            .frame(height: 28)
                    } else if let machineViewModel = viewModel.viewModel, !machineViewModel.machine.dependencies.isEmpty {
                        Toggle(isOn: $viewModel.expanded) {
                            Text(dependency.name)
                                .foregroundColor(config.textColor)
                                .frame(height: 28)
                        }.toggleStyle(ArrowToggleStyle(side: .left))
                    } else {
                        Text(dependency.name)
                            .foregroundColor(.red)
                            .padding(.leading, 25)
                            .frame(height: 28)
                    }
                }.onTapGesture {
                    focus = dependency.filePath
                }
                Spacer()
            }.padding(.leading, 10)
            .background(focus == dependency.filePath ? config.highlightColour : Color.clear)
            if viewModel.expanded, let machineViewModel = viewModel.viewModel {
                VStack {
                    ForEach(machineViewModel.machine.dependencies, id: \.filePath) { dependency in
                        if !parents.contains(dependency.filePath) {
                            DependencyView(
                                dependency: dependency,
                                viewModel: viewModel.viewModel(forDependency: dependency),
                                focus: $focus,
                                padding: padding + padding,
                                parents: parents.union([dependency.filePath])
                            )
                        }
                    }
                }.padding(.leading, 10)
            }
        }
    }
}

//struct DependencyView_Previews: PreviewProvider {
//
//    struct Preview: View {
//
//        @State var expanded: Bool = false
//
//        @State var focus: URL = Machine.initialSwiftMachine().filePath
//
//        @State var dependency: MachineDependency = MachineDependency(name: "Initial Swift Machine", filePath: Machine.initialSwiftMachine().filePath)
//
//        @State var machines: [URL: Machine] = [:]
//
//        let config = Config()
//
//        var body: some View {
//            DependencyView(
//                expanded: $expanded,
//                focus: $focus,
//                dependency: $dependency,
//                machines: $machines,
//                padding: 10
//            ).environmentObject(config)
//        }
//
//    }
//
//    static var previews: some View {
//        VStack {
//            Preview()
//        }
//    }
//}
