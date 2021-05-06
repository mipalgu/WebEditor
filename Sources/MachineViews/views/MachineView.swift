//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 24/4/21.
//

import TokamakShim
import Attributes
import Utilities
import Machines

struct MachineView: View {
    
    @ObservedObject var viewModel: MachineViewModel

    var body: some View {
        HStack {
            CanvasView(viewModel: viewModel.canvasViewModel, focus: $viewModel.focus)
            Group {
                switch viewModel.focus {
                case .machine:
                    CollapsableAttributeGroupsView(
                        machine: viewModel.machineBinding,
                        path: viewModel.path,
                        collapsed: $viewModel.attributesCollapsed,
                        label: viewModel.label,
                        selection: $viewModel.selection,
                        notifier: viewModel.notifier
                    ) {
                        DependenciesAttributesView(root: $viewModel.machine, path: viewModel.machine.path, label: "Dependencies")
                    }
                default:
                    CollapsableAttributeGroupsView(
                        machine: viewModel.machineBinding,
                        path: viewModel.path,
                        collapsed: $viewModel.attributesCollapsed,
                        label: viewModel.label,
                        selection: $viewModel.selection,
                        notifier: viewModel.notifier
                    )
                }
            }
            .frame(width: !viewModel.attributesCollapsed ? 500 : 50.0)
        }
    }
}


//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
