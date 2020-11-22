//
//  MenuViewModel.swift
//  
//
//  Created by Morgan McColl on 20/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct MenuViewModel {
    
    @Reference var machine: Ref<Machine>
    
}
