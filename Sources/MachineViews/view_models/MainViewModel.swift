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
import Machines

final class MainViewModel: ObservableObject, GlobalChangeNotifier {
    
    @Published var focus: URL
    
    let root: Root
    
    private var viewModels: [URL: MachineViewModel]
    
    lazy var dependenciesViewModel: DependenciesViewModel = {
        DependenciesViewModel(machineViewModel: { [unowned self] in
            self.viewModel(for: $0)
        })
    }()
    
    init(root: Root) {
        self.root = root
        switch root {
        case .arrangement(let viewModel):
            focus = viewModel.arrangement.filePath
            viewModels = [:]
            viewModel.notifier = self
        case .machine(let viewModel):
            focus = viewModel.machine.filePath
            self.viewModels = [viewModel.machine.filePath: viewModel]
            viewModel.notifier = self
        }
    }
    
    func viewModel(for url: URL) -> MachineViewModel? {
        if let viewModel = viewModels[url] {
            return viewModel
        }
        viewModels[url] = MachineViewModel(filePath: url, notifier: self)
        return viewModels[url]
    }
    
    public func send() {
        self.objectWillChange.send()
        self.dependenciesViewModel.objectWillChange.send()
        switch root {
        case .arrangement(let viewModel):
            if viewModel.arrangement.filePath == focus {
                viewModel.objectWillChange.send()
            } else {
                fallthrough
            }
        default:
            viewModel(for: focus)?.objectWillChange.send()
        }
    }
    
}
