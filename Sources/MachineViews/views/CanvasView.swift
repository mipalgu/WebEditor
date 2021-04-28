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
    
    @Binding var machine: Machine
    
    @EnvironmentObject var config: Config
    
    @StateObject var viewModel: MachineViewModel2
    
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
        self._machine = machine
        self._focus = focus
        guard let plist = try? String(contentsOf: machine.filePath.wrappedValue.appendingPathComponent("Layout.plist")) else {
            self._viewModel = StateObject(wrappedValue: MachineViewModel2(states: machine.states.wrappedValue))
            return
        }
        self._viewModel = StateObject(wrappedValue: MachineViewModel2(machine: machine.wrappedValue, plist: plist))
    }
    
    public var body: some View {
        Group {
            if let editState = edittingState {
                StateEditView(machine: $machine, path: machine.path.states[editState])
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
                                    Button("New State", action: { try? machine.newState() })
                                    Button("Select All", action: { viewModel.selectAll(self) }).keyboardShortcut(.init("a"))
                                    if !self.selectedObjects.isEmpty {
                                        Button("Delete Selected", action: { viewModel.deleteSelected(self) })
                                    }
                                }
                            }
                        if let curve = creatingCurve {
                            ArrowView(curve: .constant(curve), strokeNumber: 0, colour: config.highlightColour)
                        }
                        ForEach(viewModel.unattachedTransitionsAsRows, id: \.self) { row in
                            ArrowView(curve: .constant(row.data.curve), strokeNumber: 0, colour: config.errorColour)
                        }
                        ForEach(viewModel.states(machine), id: \.self) { stateRow in
                            ForEach(viewModel.transitions(stateRow), id: \.self) { transitionRow in
                                TransitionView(
                                    machine: $machine,
                                    path: machine.path.states[stateRow.index].transitions[transitionRow.index],
                                    curve: viewModel.binding(to: transitionRow.index, originatingFrom: stateRow.data).curve,
                                    strokeNumber: UInt8(transitionRow.index),
                                    focused: selectedObjects.contains(.transition(stateIndex: stateRow.index, transitionIndex: transitionRow.index))
                                )
                                .clipped()
                                .gesture(TapGesture().onEnded {
                                    viewModel.addSelectedTransition(view: self, from: stateRow.index, at: transitionRow.index)
                                }.modifiers(.shift))
                                .onTapGesture {
                                    focus = .transition(stateIndex: stateRow.index, transitionIndex: transitionRow.index)
                                    selectedObjects = [.transition(stateIndex: stateRow.index, transitionIndex: transitionRow.index)]
                                }
                                .contextMenu {
                                    Button("Straighten",action: {
                                        viewModel.straighten(state: machine.states[stateRow.index].name, transition: transitionRow.index)
                                    })
                                    Button("Delete",action: {
                                        viewModel.deleteTransition(view: self, for: stateRow.index, at: transitionRow.index)
                                    })
                                }
                            }
                        }
                        ForEach(viewModel.states(machine), id: \.self) { row in
                            if viewModel.viewModel(for: row.data).isText {
                                VStack {
                                    Text(row.data.name)
                                        .font(config.fontBody)
                                        .frame(width: textWidth, height: textHeight)
                                    //.foregroundColor(viewModel.viewModel(for: machine[keyPath: machine.path.states[index].name.keyPath]).highlighted ? config.highlightColour : config.textColor)
                                }
                                .coordinateSpace(name: coordinateSpace)
                                .position(viewModel.clampPosition(point: viewModel.viewModel(for: row.data).location, frameWidth: geometry.size.width, frameHeight: geometry.size.height, dx: textWidth / 2.0, dy: textHeight / 2.0))
                            } else {
                                VStack {
                                    StateView(
                                        machine: $machine,
                                        path: machine.path.states[row.index],
                                        expanded: Binding(
                                            get: { viewModel.viewModel(for: row.data).expanded },
                                            set: { viewModel.assignExpanded(for: row.data, newValue: $0, frameWidth: geometry.size.width, frameHeight: geometry.size.height) }
                                        ),
                                        collapsedActions: viewModel.binding(to: row.data).collapsedActions,
                                        focused: selectedObjects.contains(.state(stateIndex: row.index))
                                    ).frame(
                                        width: viewModel.viewModel(for: row.data).width,
                                        height: viewModel.viewModel(for: row.data).height
                                    )
                                }.coordinateSpace(name: coordinateSpace)
                                .position(viewModel.viewModel(for: row.data).location)
                                .gesture(TapGesture().onEnded { viewModel.addSelectedState(view: self, at: row.index) }.modifiers(.shift))
                                .onTapGesture(count: 2) { edittingState = row.index; focus = .state(stateIndex: row.index) }
                                .onTapGesture { selectedObjects = [.state(stateIndex: row.index)]; focus = .state(stateIndex: row.index) }
                                .gesture(viewModel.createTransitionGesture(forView: self, forState: row.index))
                                .gesture(viewModel.dragStateGesture(forView: self, forState: row.index, size: geometry.size))
                                .onChange(of: viewModel.viewModel(for: row.data).expanded) { _ in
                                    self.viewModel.updateTransitionLocations(source: row.data, states: machine.states)
                                }
                                .contextMenu {
                                    Button("Delete", action: {
                                        viewModel.deleteState(view: self, at: row.index)
                                        if selectedObjects.contains(.state(stateIndex: row.index)) {
                                            selectedObjects.remove(.state(stateIndex: row.index))
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
        }.focusedValue(\.saving, $saving).onChange(of: saving) { _ in
            guard let _ = try? machine.save() else {
                print(machine.errorBag.allErrors)
                return
            }
            let plist = viewModel.toPlist(machine: machine)
            guard let _ = try? plist.write(toFile: machine.filePath.appendingPathComponent("Layout.plist").path, atomically: true, encoding: .utf8) else {
                print("Failed to write plist")
                return
            }
        }
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
