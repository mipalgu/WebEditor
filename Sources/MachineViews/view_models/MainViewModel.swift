//
//  File.swift
//  
//
//  Created by Morgan McColl on 29/4/21.
//

import Foundation
import TokamakShim
import Attributes
import Machines

final class MainViewModel: ObservableObject, GlobalChangeNotifier {
    
    enum Root {
        
        var arrangement: ArrangementViewModel {
            get {
                switch self {
                case .arrangement(let arrangement):
                    return arrangement
                default:
                    fatalError("Attempting to fetch arrangment from \(self)")
                }
            } set {
                self = .arrangement(newValue)
            }
        }
        
        var machine: MachineViewModel {
            get {
                switch self {
                case .machine(let machine):
                    return machine
                default:
                    fatalError("Attempting to fetch machine from \(self)")
                }
            } set {
                self = .machine(newValue)
            }
        }
        
        case arrangement(ArrangementViewModel)
        case machine(MachineViewModel)
        
    }
    
    @Published var focus: URL
    
    var root: Root
    
    private var viewModels: [URL: MachineViewModel]
    
    init(root: Root) {
        self.root = root
        switch root {
        case .arrangement(let viewModel):
            focus = viewModel.arrangement.filePath
            viewModels = [:]
        case .machine(let viewModel):
            focus = viewModel.machine.filePath
            self.viewModels = [viewModel.machine.filePath: viewModel]
        }
    }
    
    func viewModel(for url: URL) -> MachineViewModel? {
        if let viewModel = viewModels[url] {
            return viewModel
        }
        viewModels[url] = MachineViewModel(filePath: url)
        return viewModels[url]
    }
    
    func send() {
        self.objectWillChange.send()
    }
    
}
