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

final class DependencyViewModel: ObservableObject {
    
    private let focusBinding: Binding<URL>
    
    var dependency: MachineDependency
    
    private let _machineViewModel: (URL) -> MachineViewModel?
    
    private let _dependencyViewModel: (MachineDependency) -> DependencyViewModel
    
    @Published var expanded: Bool = false
    
    var focus: URL {
        get {
            focusBinding.wrappedValue
        } set {
            focusBinding.wrappedValue = newValue
        }
    }
    
    var viewModel: MachineViewModel? {
        _machineViewModel(dependency.filePath)
    }
    
    init(dependency: MachineDependency, focus: Binding<URL>, machineViewModel: @escaping (URL) -> MachineViewModel?, dependencyViewModel: @escaping (MachineDependency) -> DependencyViewModel) {
        self.dependency = dependency
        self.focusBinding = focus
        self._machineViewModel = machineViewModel
        self._dependencyViewModel = dependencyViewModel
    }
    
    func viewModel(forDependency dependency: MachineDependency) -> DependencyViewModel {
        self._dependencyViewModel(dependency)
    }
    
}

struct DependencyView: View {
    
    @ObservedObject var viewModel: DependencyViewModel
    
    let padding: CGFloat
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        VStack {
            HStack {
                Group {
                    if let machineViewModel = viewModel.viewModel, machineViewModel.machine.dependencies.isEmpty {
                        Text(viewModel.dependency.name)
                            .foregroundColor(config.textColor)
                            .padding(.leading, 25)
                            .frame(height: 28)
                    } else if let machineViewModel = viewModel.viewModel, !machineViewModel.machine.dependencies.isEmpty {
                        Toggle(isOn: $viewModel.expanded) {
                            Text(viewModel.dependency.name)
                                .foregroundColor(config.textColor)
                                .frame(height: 28)
                        }.toggleStyle(ArrowToggleStyle(side: .left))
                    } else {
                        Text(viewModel.dependency.name)
                            .foregroundColor(.red)
                            .padding(.leading, 25)
                            .frame(height: 28)
                    }
                }.onTapGesture {
                    viewModel.focus = viewModel.dependency.filePath
                }
                Spacer()
            }.padding(.leading, 10)
            .background(viewModel.focus == viewModel.dependency.filePath ? config.highlightColour : Color.clear)
            if viewModel.expanded, let machineViewModel = viewModel.viewModel {
                VStack {
                    ForEach(machineViewModel.machine.dependencies, id: \.filePath) { dependency in
                        DependencyView(
                            viewModel: viewModel.viewModel(forDependency: dependency),
                            padding: padding + padding
                        )
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
