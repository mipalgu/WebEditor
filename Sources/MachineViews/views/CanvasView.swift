//
//  MachineView.swift
//
//
//  Created by Morgan McColl on 16/11/20.
//

import TokamakShim

import Machines
import Attributes
import Utilities
import GUUI
//import AttributeViews

public struct CanvasView: View {
    
    @EnvironmentObject var config: Config
    
    @ObservedObject var viewModel: CanvasViewModel
    
    @State var saving: Bool = false
    
    let textWidth: CGFloat = 50.0
    
    let textHeight: CGFloat = 20.0
    
//    public init(machine: Binding<Machine>, focus: Binding<Focus>) {
//        self._focus = focus
//        guard let plist = try? String(contentsOf: machine.wrappedValue.filePath.appendingPathComponent("Layout.plist")) else {
//            self.viewModel = MachineViewModel(machine: machine)
//            return
//        }
//        self.viewModel = MachineViewModel(machine: machine, plist: plist)
//    }
    
    init(viewModel: CanvasViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            if let editState = viewModel.edittingState {
                StateEditView(viewModel: viewModel.viewModel(forState: editState))
                    .gesture(viewModel.clearEdittingStateGesture)
                    .contextMenu {
                        Button("Go Back", action: { self.viewModel.edittingState = nil }).keyboardShortcut(.escape)
                    }
            } else {
                GeometryReader { (geometry: GeometryProxy) in
                    ZStack {
                        GridView()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .gesture(viewModel.clearSelectionGesture)
                            .gesture(viewModel.selectionBoxGesture)
                            .gesture(viewModel.dragCanvasGesture(bounds: geometry.size))
                            .contextMenu {
                                VStack {
                                    Button("New State", action: viewModel.newState)
                                    Button("Select All", action: viewModel.selectAll).keyboardShortcut(.init("a"))
                                    Button("Straighten Transitions", action: viewModel.straightenSelected).disabled(!viewModel.hasTransitions)
                                    Button("Delete Selected", action: viewModel.deleteSelected).disabled(viewModel.selectedObjects.isEmpty)
                                }
                            }
                        if let curve = viewModel.creatingCurve {
                            ArrowView(curve: .constant(curve), strokeNumber: 0, colour: config.highlightColour)
                        }
                        ForEach(viewModel.stateNames, id: \.self) { stateName in
                            ForEach(viewModel.transitions(forState: stateName), id: \.self) { transitionIndex in
                                TransitionView(
                                    viewModel: viewModel.viewModel(forTransition: transitionIndex, attachedToState: stateName).tracker,
                                    focused: viewModel.selectedObjects.contains(.transition(stateIndex: viewModel.viewModel(forState: stateName).index, transitionIndex: transitionIndex)),
                                    strokeView: { TransitionStrokeView(viewModel: viewModel.viewModel(forTransition: transitionIndex, attachedToState: stateName), curve: $0) },
                                    label: { TransitionLabelView(viewModel: viewModel.viewModel(forTransition: transitionIndex, attachedToState: stateName)) },
                                    editLabel: { TransitionEditLabelView(viewModel: viewModel.viewModel(forTransition: transitionIndex, attachedToState: stateName)) }
                                )
                                .clipped()
                                .gesture(viewModel.addTransitionToSelectionGesture(transition: transitionIndex, state: stateName))
                                .gesture(viewModel.makeTransitionSelectionGesture(transition: transitionIndex, state: stateName))
                                .contextMenu {
                                    Button("Straighten", action: {
                                        viewModel.straighten(stateName: stateName, transitionIndex: transitionIndex)
                                    })
                                    if viewModel.selectedObjects.contains(.transition(stateIndex: viewModel.viewModel(forState: stateName).index, transitionIndex: transitionIndex)) {
                                        Button("Delete Selected", action: viewModel.deleteSelected)
                                    } else {
                                        Button("Delete", action: {
                                            viewModel.deleteTransition(transitionIndex, attachedTo: stateName)
                                        }).keyboardShortcut(.delete)
                                    }
                                }
                            }
                        }
                        ForEach(viewModel.stateNames, id: \.self) { stateName in
                            CanvasObjectView(
                                viewModel: viewModel.viewModel(forState: stateName).tracker,
                                coordinateSpace: viewModel.coordinateSpace,
                                textRepresentation: viewModel.viewModel(forState: stateName).name,
                                frame: geometry.size
                            ) {
                                StateView(
                                    viewModel: viewModel.viewModel(forState: stateName),
                                    focused: viewModel.selectedObjects.contains(.state(stateIndex: viewModel.viewModel(forState: stateName).index))
                                )
                            }
                            .gesture(viewModel.addStateToSelectionGesture(state: stateName))
                            .gesture(viewModel.setEdittingStateGesture(state: stateName))
                            .gesture(viewModel.makeStateSelectionGesture(state: stateName))
                            .gesture(viewModel.createTransitionGesture)
                            .gesture(viewModel.dragStateGesture(stateName: stateName, bounds: geometry.size))
                            .contextMenu {
                                if viewModel.selectedObjects.contains(.state(stateIndex: viewModel.viewModel(forState: stateName).index)) {
                                    Button("Straighten Transitions", action: viewModel.straightenSelected).disabled(!viewModel.hasTransitions)
                                    Button("Delete Selected", action: viewModel.deleteSelected)
                                } else {
                                    Button("Delete", action: {
                                        viewModel.deleteState(stateName)
                                    })
                                }
                            }
                        }
                        if let rect = viewModel.selectedBox {
                            Rectangle()
                                .background(config.highlightColour)
                                .opacity(0.2)
                                .frame(width: rect.width, height: rect.height)
                                .position(x: rect.minX + rect.width / 2, y: rect.minY + rect.height / 2)
                        }
                    }.frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .onChange(of: geometry.size) {
                        viewModel.canvasSize = $0
                    }
                }
            }
        }
    }
    
}

//struct CanvasView_Previews: PreviewProvider {
//    
//    struct Parent: View {
//        
//        
//        @State var machine: Machine = Machine.initialSwiftMachine()
//        
//        var body: some View {
//            Preview(viewModel: CanvasViewModel(machine: $machine))
//        }
//        
//    }
//    
//    struct Preview: View {
//        
//        @StateObject var viewModel: CanvasViewModel
//        
//        @State var focus: Focus = .machine
//        
//        let config = Config()
//        
//        var body: some View {
//            CanvasView(viewModel: viewModel, focus: $focus).environmentObject(config)
//        }
//        
//    }
//    
//    static var previews: some View {
//        VStack {
//            Parent()
//        }
//    }
//}
