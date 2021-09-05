//
//  File.swift
//  
//
//  Created by Morgan McColl on 29/4/21.
//

import Foundation
import TokamakShim
import AttributeViews
import Attributes
import MetaMachines
import CXXMachines

final class MainViewModel: ObservableObject, GlobalChangeNotifier {
    
    struct IOError: Error {
        
        var message: String
        
    }
    
    @Published var focus: String
    
    let root: Root
    
    private var viewModels: [String: MachineViewModel]
    
//    lazy var dependenciesViewModel: DependenciesViewModel = {
//        DependenciesViewModel(machineViewModel: { [unowned self] in
//            self.viewModel(for: $0)
//        })
//    }()
    
    var subView: AnyView {
        switch root {
        case .arrangement(let arrangementViewModel):
            if focus == arrangementViewModel.arrangement.name {
                return AnyView(ArrangementView(viewModel: arrangementViewModel))
            }
            fallthrough
        default:
            guard let machineViewModel = viewModel(for: focus) else {
                return AnyView(EmptyView())
            }
            return AnyView(MachineView(viewModel: machineViewModel))
        }
    }
    
    convenience init(wrapper: FileWrapper) throws {
        guard let filename = wrapper.filename else {
            throw IOError(message: "Wrapper does not have a file name.")
        }
        if filename.hasPrefix(".machine") {
            try self.init(root: .machine(MachineViewModel(wrapper: wrapper, notifier: nil)))
            return
        }
        throw IOError(message: "Attempting to open an unsupported file format.")
    }
    
    init(root: Root) {
        self.root = root
        switch root {
        case .arrangement(let viewModel):
            focus = viewModel.arrangement.name
            viewModels = [:]
            viewModel.notifier = self
        case .machine(let viewModel):
            focus = viewModel.machine.name
            self.viewModels = [viewModel.machine.name: viewModel]
            viewModel.notifier = self
        }
    }
    
    func viewModel(for name: String) -> MachineViewModel? {
        if let viewModel = viewModels[name] {
            return viewModel
        }
        fatalError("Attempting to laod view model of dependent machine.")
        //viewModels[name] = MachineViewModel(filePath: machineURL, notifier: self)
        //return viewModels[url]
    }
    
    public func send() {
        //self.dependenciesViewModel.send()
        switch root {
        case .arrangement(let viewModel):
            if viewModel.arrangement.name == focus {
                viewModel.send()
            } else {
                fallthrough
            }
        default:
            viewModel(for: focus)?.send()
        }
        self.objectWillChange.send()
    }
    
}
