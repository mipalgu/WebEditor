//
//  StateView.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

import TokamakShim

import Machines
import Attributes
import AttributeViews
import Utilities

struct StateView: View {
    
    @ObservedObject var viewModel: StateViewModel
    
    let coordinateSpace: String
    
    let frame: CGSize

    let focused: Bool
    
    init(viewModel: StateViewModel, coordinateSpace: String, frame: CGSize, focused: Bool = false) {
        self.viewModel = viewModel
        self.coordinateSpace = coordinateSpace
        self.frame = frame
        self.focused = focused
    }
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Group {
            if viewModel.expanded {
                StateExpandedView(viewModel: viewModel.actionsViewModel, focused: focused) {
                    StateTitleView(root: $viewModel.machine, path: viewModel.path.name, expanded: $viewModel.expanded)
                }
            } else {
                StateCollapsedView(focused: focused) {
                    StateTitleView(root: $viewModel.machine, path: viewModel.path.name, expanded: $viewModel.expanded)
                }
            }
        }
//        .position(tracker.location)
//        .coordinateSpace(name: coordinateSpace)
//        .position(tracker.location)
        .frame(
            width: viewModel.width,
            height: viewModel.height
        )
    }
}

//struct StateView_Previews: PreviewProvider {
//    
//    struct Expanded_Preview: View {
//        
//        @State var machine: Machine = Machine.initialSwiftMachine()
//        
//        
//        @State var expanded: Bool = true
//        
//        let config = Config()
//        
//        var body: some View {
//            StateView(
//                state: StateViewModel(
//                    machine: $machine,
//                    path: machine.path.states[0],
//                    state: $machine.states[0],
//                    stateIndex: 0,
//                    cache: ViewCache(machine: $machine),
//                    notifier: nil
//                ),
//                tracker: StateTracker(expanded: expanded),
//                coordinateSpace: "MAIN_VIEW",
//                frame: CGSize(width: 1000.0, height: 1000.0)
//            ).environmentObject(config)
//        }
//        
//    }
//    
//    struct Collapsed_Preview: View {
//        
//        @State var machine: Machine = Machine.initialSwiftMachine()
//        
//        @State var expanded: Bool = false
//        
//        @State var collapsedActions: [String: Bool] = [:]
//        
//        let config = Config()
//        
//        var body: some View {
//            StateView(
//                state: StateViewModel(
//                    machine: $machine,
//                    path: machine.path.states[0],
//                    state: $machine.states[0],
//                    stateIndex: 0,
//                    cache: ViewCache(machine: $machine),
//                    notifier: nil
//                ),
//                tracker: StateTracker(expanded: expanded),
//                coordinateSpace: "MAIN_VIEW",
//                frame: CGSize(width: 1000.0, height: 1000.0)
//            ).environmentObject(config)
//        }
//        
//    }
//    
//    static var previews: some View {
//        VStack {
//            Collapsed_Preview().frame(width: 200, height: 100)
//            Expanded_Preview().frame(minHeight: 400)
//        }
//    }
//}
