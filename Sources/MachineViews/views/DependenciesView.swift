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
    
    @Binding var machines: [Ref<Machine>]
    
    @Binding var rootMachines: [MachineDependency]
    
    @Binding var currentIndex: Int
    
    @Binding var collapsed: Bool
    
    let collapseLeft: Bool
    let buttonSize: CGFloat
    let buttonWidth: CGFloat
    let buttonHeight: CGFloat
    
    let label = "Dependencies"
    
    @State var rootMachinesExpanded: Set<String> = Set()
    
    var rootMachineModels: [Ref<Machine>] {
        rootMachines.compactMap { rootMachine in  machines.first(where: { $0.value.name == rootMachine.name }) }
    }
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        EmptyView()
    }
    
}
