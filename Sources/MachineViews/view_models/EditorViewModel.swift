//
//  EditorViewModel.swift
//  
//
//  Created by Morgan McColl on 21/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

public class EditorViewModel: ObservableObject {
    
    @Published var machines: [Ref<Machine>]
    
    @Published var mainView: ViewType = .none
    
    @Published var focusedView: ViewType = .none
    
    public init(machines: [Ref<Machine>], mainView: ViewType = .none, focusedView: ViewType = .none) {
        self.machines = machines
        self.mainView = mainView
        self.focusedView = focusedView
    }
    
}
