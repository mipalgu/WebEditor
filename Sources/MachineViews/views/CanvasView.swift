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
    
    @ObservedObject var viewModel: MachineViewModel
    
    @Binding var focus: Focus
    
    @State var selectedBox: (CGPoint, CGPoint)?
    
    @State var selectedObjects: Set<ViewType> = []
    
    @State var creatingCurve: Curve? = nil
    
    @State var edittingState: Int? = nil
    
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
    
    init(viewModel: MachineViewModel, focus: Binding<Focus>) {
        self.viewModel = viewModel
        self._focus = focus
    }
    
    public var body: some View {
        Group {
            if let editState = edittingState {
                StateEditView(
                    titleViewModel: viewModel.viewModel(for: viewModel.machine.states[editState].name).title,
                    actionViewModels: viewModel.viewModel(for: viewModel.machine.states[editState].name).actions
                )
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
                            .gesture(viewModel.selectionBoxGesture(forView: self))
                            .gesture(viewModel.dragCanvasGesture(coordinateSpace: coordinateSpace, size: geometry.size))
                            .contextMenu {
                                VStack {
                                    Button("New State", action: { viewModel.createState() })
                                    Button("Select All", action: { viewModel.selectAll(self) }).keyboardShortcut(.init("a"))
                                    if !self.selectedObjects.isEmpty {
                                        Button("Delete Selected", action: { viewModel.deleteSelected(self) })
                                    }
                                    Button("Save", action: {
                                        guard let _ = try? viewModel.machine.save() else {
                                            print(viewModel.machine.errorBag.allErrors)
                                            return
                                        }
                                        let plist = viewModel.plist
                                        guard let _ = try? plist.write(toFile: viewModel.machine.filePath.appendingPathComponent("Layout.plist").path, atomically: true, encoding: .utf8) else {
                                            print("Failed to write plist")
                                            return
                                        }
                                    })
                                }
                            }
                        if let curve = creatingCurve {
                            ArrowView(curve: .constant(curve), strokeNumber: 0, colour: config.highlightColour)
                        }
//                        ForEach(viewModel.unattachedTransitionsAsRows, id: \.self) { row in
//                            ArrowView(curve: .constant(row.data.curve), strokeNumber: 0, colour: config.errorColour)
//                        }
                        ForEach(viewModel.cache.viewModels(), id: \.self) { stateViewModel in
                            ForEach(viewModel.cache.transitions(source: stateViewModel.name), id: \.self) { transitionViewModel in
                                TransitionView(
                                    viewModel: transitionViewModel,
                                    tracker: viewModel.tracker(for: transitionViewModel.transitionIndex, originating: stateViewModel.name),
                                    strokeNumber: UInt8(transitionViewModel.transitionIndex),
                                    focused: selectedObjects.contains(.transition(stateIndex: stateViewModel.stateIndex, transitionIndex: transitionViewModel.transitionIndex))
                                )
                                .clipped()
                                .gesture(TapGesture().onEnded {
                                    viewModel.addSelectedTransition(view: self, from: stateViewModel.stateIndex, at: transitionViewModel.transitionIndex)
                                }.modifiers(.shift))
                                .onTapGesture {
                                    focus = .transition(stateIndex: stateViewModel.stateIndex, transitionIndex: transitionViewModel.transitionIndex)
                                    selectedObjects = [.transition(stateIndex: stateViewModel.stateIndex, transitionIndex: transitionViewModel.transitionIndex)]
                                }
                                .contextMenu {
                                    Button("Straighten",action: {
                                        viewModel.straighten(state: stateViewModel.name, transitionIndex: transitionViewModel.transitionIndex)
                                    })
                                    Button("Delete",action: {
                                        viewModel.deleteTransition(view: self, for: stateViewModel.stateIndex, at: transitionViewModel.transitionIndex)
                                    })
                                }
                            }
                        }
                        ForEach(viewModel.cache.viewModels(), id: \.self) { stateViewModel in
                            if viewModel.tracker(for: stateViewModel.name).isText {
                                VStack {
                                    Text(stateViewModel.name)
                                        .font(config.fontBody)
                                        .frame(width: textWidth, height: textHeight)
//                                    .foregroundColor(viewModel.viewModel(for: machine[keyPath: machine.path.states[index].name.keyPath]).highlighted ? config.highlightColour : config.textColor)
                                }
                                .coordinateSpace(name: coordinateSpace)
                                .position(viewModel.clampPosition(point: viewModel.tracker(for: stateViewModel.name).location, frame: geometry.size, dx: textWidth / 2.0, dy: textHeight / 2.0))
                            } else {
                                VStack {
                                    StateView(
                                        state: stateViewModel,
                                        tracker: viewModel.tracker(for: stateViewModel.name),
                                        coordinateSpace: coordinateSpace,
                                        frame: geometry.size,
                                        focused: selectedObjects.contains(.state(stateIndex: stateViewModel.stateIndex))
                                    )
                                    .onChange(of: viewModel.tracker(for: stateViewModel.name).expanded) { _ in
                                        self.viewModel.correctTransitionLocations(for: stateViewModel.state.wrappedValue)
                                    }
//                                    .frame(
//                                        width: viewModel.tracker(for: viewModel.machine.states[stateIndex].name).width,
//                                        height: viewModel.tracker(for: viewModel.machine.states[stateIndex].name).height
//                                    )
                                }
                                .coordinateSpace(name: coordinateSpace)
                                .position(viewModel.tracker(for: stateViewModel.name).location)
                                .gesture(TapGesture().onEnded { viewModel.addSelectedState(view: self, at: stateViewModel.stateIndex) }.modifiers(.shift))
                                .onTapGesture(count: 2) { edittingState = stateViewModel.stateIndex; focus = .state(stateIndex: stateViewModel.stateIndex) }
                                .onTapGesture { selectedObjects = [.state(stateIndex: stateViewModel.stateIndex)]; focus = .state(stateIndex: stateViewModel.stateIndex) }
                                .gesture(viewModel.createTransitionGesture(forView: self, forState: stateViewModel.stateIndex))
                                .gesture(viewModel.dragStateGesture(forView: self, forState: stateViewModel.stateIndex, size: geometry.size))
                                .onChange(of: viewModel.tracker(for: stateViewModel.name).expanded) { _ in
                                    self.viewModel.updateTransitionLocations(source: stateViewModel.state.wrappedValue)
                                }
                                .contextMenu {
                                    Button("Delete", action: {
                                        viewModel.deleteState(view: self, at: stateViewModel.stateIndex)
                                        if selectedObjects.contains(.state(stateIndex: stateViewModel.stateIndex)) {
                                            selectedObjects.remove(.state(stateIndex: stateViewModel.stateIndex))
                                        }
                                    })
                                }
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

struct CanvasView_Previews: PreviewProvider {
    
    struct Parent: View {
        
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        var body: some View {
            Preview(viewModel: MachineViewModel(machine: machine))
        }
        
    }
    
    struct Preview: View {
        
        @StateObject var viewModel: MachineViewModel
        
        @State var focus: Focus = .machine
        
        let config = Config()
        
        var body: some View {
            CanvasView(viewModel: viewModel, focus: $focus).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Parent()
        }
    }
}
