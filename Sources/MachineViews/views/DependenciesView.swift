//
//  SwiftUIView.swift
//
//
//  Created by Morgan McColl on 23/11/20.
//

import TokamakShim

import Machines
import Attributes
import Utilities

final class DependenciesViewModel: ObservableObject {
    
    private let focusBinding: Binding<URL>
    
    private let _machineViewModel: (URL) -> MachineViewModel?
    
    private var dependencyViewModels: [URL: DependencyViewModel] = [:]
    
    @Published var expanded: Bool = false
    
    var focus: URL {
        get {
            focusBinding.wrappedValue
        } set {
            focusBinding.wrappedValue = newValue
        }
    }
    
    init(focus: Binding<URL>, machineViewModel: @escaping (URL) -> MachineViewModel?) {
        self.focusBinding = focus
        self._machineViewModel = machineViewModel
    }
    
    func machineViewModel(forURL url: URL) -> MachineViewModel? {
        self._machineViewModel(url)
    }
    
    func viewModel(forDependency dependency: MachineDependency) -> DependencyViewModel {
        if let viewModel = dependencyViewModels[dependency.filePath] {
            return viewModel
        }
        let newViewModel = DependencyViewModel(
            url: dependency.filePath,
            focus: focusBinding,
            machineViewModel: _machineViewModel,
            dependencyViewModel: { [unowned self] in
                self.viewModel(forDependency: $0)
            }
        )
        dependencyViewModels[dependency.filePath] = newViewModel
        return newViewModel
    }
    
}

struct DependenciesView: View {
    
    let root: Root
    
    @ObservedObject var viewModel: DependenciesViewModel
    
    @Binding var width: CGFloat
    
    @EnvironmentObject var config: Config
    
    let padding: CGFloat = 10
    
    init(root: Root, viewModel: DependenciesViewModel, width: Binding<CGFloat> = .constant(200)) {
        self.root = root
        self.viewModel = viewModel
        self._width = width
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Toggle(isOn: $viewModel.expanded) {
                        Text(root.name.pretty)
                    }
                    .toggleStyle(ArrowToggleStyle(side: .left))
                    .onTapGesture {
                        viewModel.focus = root.filePath
                    }
                    Spacer()
                }.padding(.leading, padding)
            }.background(viewModel.focus == root.filePath ? config.highlightColour : Color.clear)
            if viewModel.expanded {
                VStack {
                    ForEach(root.dependencies, id: \.filePath) { dependency in
                        DependencyView(
                            dependency: dependency,
                            viewModel: viewModel.viewModel(forDependency: dependency),
                            padding: padding + padding,
                            parents: [root.filePath]
                        )
                    }
                }.padding(.leading, padding)
            }
            Spacer()
        }.frame(width: width, alignment: .leading)
    }
    
}

//struct Dependencies_Previews: PreviewProvider {
//
//    struct Preview: View {
//
//        @State var focus: URL = Machine.initialSwiftMachine().filePath
//
//        @State var name: String = "Initial Swift Machine"
//
//        @State var url: URL = Machine.initialSwiftMachine().filePath
//
//        @State var dependencies: [MachineDependency] = Machine.initialSwiftMachine().dependencies
//
//        @State var machines: [URL: Machine] = [:]
//
//        let config = Config()
//
//        var body: some View {
//            DependenciesView(
//                focus: $focus,
//                name: $name,
//                url: $url,
//                dependencies: $dependencies,
//                machines: $machines,
//                width: .constant(200)
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
