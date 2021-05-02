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
    
    public init(machine: Binding<Machine>, focus: Binding<Focus>) {
        self._focus = focus
        guard let plist = try? String(contentsOf: machine.wrappedValue.filePath.appendingPathComponent("Layout.plist")) else {
            self.viewModel = MachineViewModel(machine: machine)
            return
        }
        self.viewModel = MachineViewModel(machine: machine, plist: plist)
    }
    
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
                                }
                            }
                        if let curve = creatingCurve {
                            ArrowView(curve: .constant(curve), strokeNumber: 0, colour: config.highlightColour)
                        }
//                        ForEach(viewModel.unattachedTransitionsAsRows, id: \.self) { row in
//                            ArrowView(curve: .constant(row.data.curve), strokeNumber: 0, colour: config.errorColour)
//                        }
                        ForEach(Array(viewModel.machine.states.indices), id: \.self) { stateIndex in
                            ForEach(Array(viewModel.machine.states[stateIndex].transitions.indices), id: \.self) { transitionIndex in
                                TransitionView(
                                    viewModel: viewModel.transition(for: transitionIndex, in: viewModel.machine.states[stateIndex].name),
                                    tracker: viewModel.tracker(for: transitionIndex, originating: viewModel.machine.states[stateIndex].name),
                                    strokeNumber: UInt8(transitionIndex),
                                    focused: selectedObjects.contains(.transition(stateIndex: stateIndex, transitionIndex: transitionIndex))
                                )
                                .clipped()
                                .gesture(TapGesture().onEnded {
                                    viewModel.addSelectedTransition(view: self, from: stateIndex, at: transitionIndex)
                                }.modifiers(.shift))
                                .onTapGesture {
                                    focus = .transition(stateIndex: stateIndex, transitionIndex: transitionIndex)
                                    selectedObjects = [.transition(stateIndex: stateIndex, transitionIndex: transitionIndex)]
                                }
                                .contextMenu {
                                    Button("Straighten",action: {
                                        viewModel.straighten(state: viewModel.machine.states[stateIndex].name, transitionIndex: transitionIndex)
                                    })
                                    Button("Delete",action: {
                                        viewModel.deleteTransition(view: self, for: stateIndex, at: transitionIndex)
                                    })
                                }
                            }
                        }
                        ForEach(Array(viewModel.machine.states.indices), id: \.self) { stateIndex in
                            if viewModel.tracker(for: viewModel.machine.states[stateIndex].name).isText {
                                VStack {
                                    Text(viewModel.machine.states[stateIndex].name)
                                        .font(config.fontBody)
                                        .frame(width: textWidth, height: textHeight)
//                                    .foregroundColor(viewModel.viewModel(for: machine[keyPath: machine.path.states[index].name.keyPath]).highlighted ? config.highlightColour : config.textColor)
                                }
                                .coordinateSpace(name: coordinateSpace)
                                .position(viewModel.clampPosition(point: viewModel.tracker(for: viewModel.machine.states[stateIndex].name).location, frame: geometry.size, dx: textWidth / 2.0, dy: textHeight / 2.0))
                            } else {
                                VStack {
                                    StateView(
                                        state: viewModel.viewModel(for: viewModel.machine.states[stateIndex].name),
                                        tracker: viewModel.tracker(for: viewModel.machine.states[stateIndex].name),
                                        coordinateSpace: coordinateSpace,
                                        frame: geometry.size,
                                        focused: selectedObjects.contains(.state(stateIndex: stateIndex))
                                    )
                                    .onChange(of: viewModel.tracker(for: viewModel.machine.states[stateIndex].name).expanded) { _ in
                                        self.viewModel.correctTransitionLocations(for: viewModel.machine.states[stateIndex])
                                    }
//                                    .frame(
//                                        width: viewModel.tracker(for: viewModel.machine.states[stateIndex].name).width,
//                                        height: viewModel.tracker(for: viewModel.machine.states[stateIndex].name).height
//                                    )
                                }
                                .coordinateSpace(name: coordinateSpace)
                                .position(viewModel.tracker(for: viewModel.machine.states[stateIndex].name).location)
                                .gesture(TapGesture().onEnded { viewModel.addSelectedState(view: self, at: stateIndex) }.modifiers(.shift))
                                .onTapGesture(count: 2) { edittingState = stateIndex; focus = .state(stateIndex: stateIndex) }
                                .onTapGesture { selectedObjects = [.state(stateIndex: stateIndex)]; focus = .state(stateIndex: stateIndex) }
                                .gesture(viewModel.createTransitionGesture(forView: self, forState: stateIndex))
                                .gesture(viewModel.dragStateGesture(forView: self, forState: stateIndex, size: geometry.size))
                                .onChange(of: viewModel.tracker(for: viewModel.machine.states[stateIndex].name).expanded) { _ in
                                    self.viewModel.updateTransitionLocations(source: viewModel.machine.states[stateIndex])
                                }
                                .contextMenu {
                                    Button("Delete", action: {
                                        viewModel.deleteState(view: self, at: stateIndex)
                                        if selectedObjects.contains(.state(stateIndex: stateIndex)) {
                                            selectedObjects.remove(.state(stateIndex: stateIndex))
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
            guard let _ = try? machine.save() else {
                print(machine.errorBag.allErrors)
                return
            }
            let plist = viewModel.toPlist(machine: machine)
            guard let _ = try? plist.write(toFile: machine.filePath.appendingPathComponent("Layout.plist").path, atomically: true, encoding: .utf8) else {
                print("Failed to write plist")
                return
            }
        }*/
    }
    
}

struct CanvasView_Previews: PreviewProvider {
    
    struct Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        @State var focus: Focus = .machine
        
        let config = Config()
        
        var body: some View {
            CanvasView(machine: $machine, focus: $focus).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Preview()
        }
    }
}
