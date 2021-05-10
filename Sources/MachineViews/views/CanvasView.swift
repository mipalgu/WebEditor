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
    
    @Binding var focus: Focus
    
    @State var selectedBox: (CGPoint, CGPoint)?
    
    @State var selectedObjects: Set<ViewType> = []
    
    @State var creatingCurve: Curve? = nil
    
    @State var edittingState: StateName? = nil
    
    @State var saving: Bool = false
    
    let coordinateSpace = "MAIN_VIEW"
    
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
    
    init(viewModel: CanvasViewModel, focus: Binding<Focus>) {
        self.viewModel = viewModel
        self._focus = focus
    }
    
    public var body: some View {
        Group {
            if let editState = edittingState {
                StateEditView(viewModel: viewModel.viewModel(forState: editState))
                    .onTapGesture(count: 2) {
                        edittingState = nil
                        focus = .machine
                    }
                    .contextMenu {
                        Button("Go Back", action: { edittingState = nil }).keyboardShortcut(.escape)
                    }
            } else {
                GeometryReader { (geometry: GeometryProxy) in
                    ZStack {
                        GridView()
                            .frame(width: geometry.size.width, height: geometry.size.height)
//                            .onTapGesture(count: 2) { try? machine.newState() }
                            .onTapGesture { selectedObjects = []; focus = .machine }
                            //.gesture(viewModel.selectionBoxGesture(forView: self))
                            //.gesture(viewModel.dragCanvasGesture(coordinateSpace: coordinateSpace, size: geometry.size))
//                            .contextMenu {
//                                VStack {
//                                    Button("New State", action: { viewModel.createState() })
//                                    Button("Select All", action: { viewModel.selectAll(self) }).keyboardShortcut(.init("a"))
//                                    if !self.selectedObjects.isEmpty {
//                                        Button("Delete Selected", action: { viewModel.deleteSelected(self) })
//                                    }
//                                    Button("Save", action: {
//                                        guard let _ = try? viewModel.machine.save() else {
//                                            print(viewModel.machine.errorBag.allErrors)
//                                            return
//                                        }
//                                        let plist = viewModel.plist
//                                        guard let _ = try? plist.write(toFile: viewModel.machine.filePath.appendingPathComponent("Layout.plist").path, atomically: true, encoding: .utf8) else {
//                                            print("Failed to write plist")
//                                            return
//                                        }
//                                    })
//                                }
//                            }
                        if let curve = creatingCurve {
                            ArrowView(curve: .constant(curve), strokeNumber: 0, colour: config.highlightColour)
                        }
//                        ForEach(viewModel.unattachedTransitionsAsRows, id: \.self) { row in
//                            ArrowView(curve: .constant(row.data.curve), strokeNumber: 0, colour: config.errorColour)
//                        }
                        ForEach(viewModel.stateNames, id: \.self) { stateName in
                            ForEach(viewModel.transitions(forState: stateName), id: \.self) { transitionIndex in
                                TransitionView(
                                    viewModel: viewModel.viewModel(forTransition: transitionIndex, attachedToState: stateName),
                                    focused: selectedObjects.contains(.transition(stateIndex: viewModel.viewModel(forState: stateName).index, transitionIndex: transitionIndex))
                                )
                                .clipped()
//                                .gesture(TapGesture().onEnded {
//                                    viewModel.addSelectedTransition(view: self, from: viewModel.viewModel(for: stateName).stateIndex, at: transitionViewModel.transitionIndex)
//                                }.modifiers(.shift))
//                                .onTapGesture {
//                                    focus = .transition(stateIndex: viewModel.viewModel(for: stateName).stateIndex, transitionIndex: transitionViewModel.transitionIndex)
//                                    selectedObjects = [.transition(stateIndex: viewModel.viewModel(for: stateName).stateIndex, transitionIndex: transitionViewModel.transitionIndex)]
//                                }
//                                .contextMenu {
//                                    Button("Straighten",action: {
//                                        viewModel.straighten(state: stateName, transitionIndex: transitionViewModel.transitionIndex)
//                                    })
//                                    Button("Delete",action: {
//                                        viewModel.deleteTransition(view: self, for: viewModel.viewModel(for: stateName).stateIndex, at: transitionViewModel.transitionIndex)
//                                    })
//                                }
                            }
                        }
                        ForEach(viewModel.stateNames, id: \.self) { stateName in
                            if viewModel.viewModel(forState: stateName).tracker.isText {
                                VStack {
                                    Text(stateName)
                                        .font(config.fontBody)
                                        .frame(width: textWidth, height: textHeight)
//                                    .foregroundColor(viewModel.viewModel(for: machine[keyPath: machine.path.states[index].name.keyPath]).highlighted ? config.highlightColour : config.textColor)
                                }
                                .coordinateSpace(name: coordinateSpace)
//                                .position(viewModel.clampPosition(point: viewModel.tracker(for: stateName).location, frame: geometry.size, dx: textWidth / 2.0, dy: textHeight / 2.0))
                            } else {
                                VStack {
                                    CanvasObjectView(
                                        viewModel: viewModel.viewModel(forState: stateName).tracker,
                                        coordinateSpace: coordinateSpace
                                    ) {
                                        StateView(
                                            viewModel: viewModel.viewModel(forState: stateName),
                                            focused: selectedObjects.contains(.state(stateIndex: viewModel.viewModel(forState: stateName).index))
                                        )
                                        .onChange(of: viewModel.viewModel(forState: stateName).expanded) { _ in
    //                                        self.viewModel.correctTransitionLocations(for: viewModel.viewModel(for: stateName).state.wrappedValue)
                                        }
                                    }
//                                    .frame(
//                                        width: viewModel.tracker(for: viewModel.machine.states[stateIndex].name).width,
//                                        height: viewModel.tracker(for: viewModel.machine.states[stateIndex].name).height
//                                    )
                                }
//                                .gesture(TapGesture().onEnded { viewModel.addSelectedState(view: self, at: viewModel.viewModel(for: stateName).stateIndex) }.modifiers(.shift))
//                                .onTapGesture(count: 2) { edittingState = stateName; focus = .state(stateIndex: viewModel.viewModel(for: stateName).stateIndex) }
//                                .onTapGesture { selectedObjects = [.state(stateIndex: viewModel.viewModel(for: stateName).stateIndex)]; focus = .state(stateIndex: viewModel.viewModel(for: stateName).stateIndex) }
//                                .gesture(viewModel.createTransitionGesture(forView: self, forState: viewModel.viewModel(for: stateName).stateIndex))
//                                .gesture(viewModel.dragStateGesture(forView: self, forState: viewModel.viewModel(for: stateName).stateIndex, size: geometry.size))
//                                .onChange(of: viewModel.tracker(for: stateName).expanded) { _ in
//                                    self.viewModel.updateTransitionLocations(source: viewModel.viewModel(for: stateName).state.wrappedValue)
//                                }
//                                .contextMenu {
//                                    Button("Delete", action: {
//                                        viewModel.deleteState(view: self, at: viewModel.viewModel(for: stateName).stateIndex)
//                                        if selectedObjects.contains(.state(stateIndex: viewModel.viewModel(for: stateName).stateIndex)) {
//                                            selectedObjects.remove(.state(stateIndex: viewModel.viewModel(for: stateName).stateIndex))
//                                        }
//                                    })
//                                }
                            }
                        }
                        if selectedBox != nil {
                            Rectangle()
                                .background(config.highlightColour)
                                .opacity(0.2)
                                .frame(width: width(point0: selectedBox!.0, point1: selectedBox!.1), height: height(point0: selectedBox!.0, point1: selectedBox!.1))
                                .position(center(point0: selectedBox!.0, point1: selectedBox!.1))
                        }
                    }.frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                }
            }
        }/*.focusedValue(\.saving, $saving).onChange(of: saving) { _ in
            guard let _ = try? viewModel.machine.save() else {
                print(viewModel.machine.errorBag.allErrors)
                return
            }
            let plist = viewModel.plist
            guard let _ = try? plist.write(toFile: viewModel.machine.filePath.appendingPathComponent("Layout.plist").path, atomically: true, encoding: .utf8) else {
                print("Failed to write plist")
                return
            }
        }*/
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
