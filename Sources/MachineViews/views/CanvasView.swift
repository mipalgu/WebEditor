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
    
    @State var creatingCurve: Curve? = nil
    
    @State var edittingState: StateName? = nil
    
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
                            .onTapGesture {
                                viewModel.selectedObjects = []
                                focus = .machine
                            }
                            .gesture(viewModel.selectionBoxGesture)
                            .gesture(viewModel.dragCanvasGesture)
                            .contextMenu {
                                VStack {
                                    Button("New State", action: { viewModel.newState() })
                                    /*Button("Select All", action: { viewModel.selectAll(self) }).keyboardShortcut(.init("a"))
                                    if !self.selectedObjects.isEmpty {
                                        Button("Delete Selected", action: { viewModel.deleteSelected(self) })
                                    }*/
                                    /*Button("Save", action: {
                                        guard let _ = try? viewModel.machine.save() else {
                                            print(viewModel.machine.errorBag.allErrors)
                                            return
                                        }
                                        let plist = viewModel.plist
                                        guard let _ = try? plist.write(toFile: viewModel.machine.filePath.appendingPathComponent("Layout.plist").path, atomically: true, encoding: .utf8) else {
                                            print("Failed to write plist")
                                            return
                                        }
                                    })*/
                                }
                            }
                        if let curve = creatingCurve {
                            ArrowView(curve: .constant(curve), strokeNumber: 0, colour: config.highlightColour)
                        }
//                        ForEach(viewModel.unattachedTransitionsAsRows, id: \.self) { row in
//                            ArrowView(curve: .constant(row.data.curve), strokeNumber: 0, colour: config.errorColour)
//                        }
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
//                                .gesture(TapGesture().onEnded {
//                                    viewModel.addSelectedTransition(view: self, from: viewModel.viewModel(for: stateName).stateIndex, at: transitionViewModel.transitionIndex)
//                                }.modifiers(.shift))
                                .onTapGesture {
                                    focus = .transition(stateIndex: viewModel.viewModel(forState: stateName).index, transitionIndex: transitionIndex)
                                    viewModel.selectedObjects = [.transition(stateIndex: viewModel.viewModel(forState: stateName).index, transitionIndex: transitionIndex)]
                                }
                                .contextMenu {
//                                    Button("Straighten",action: {
//                                        viewModel.straighten(state: stateName, transitionIndex: transitionViewModel.transitionIndex)
//                                    })
                                    Button("Delete",action: {
                                        viewModel.deleteTransition(transitionIndex, attachedTo: stateName)
                                    }).keyboardShortcut(.delete)
                                }
                            }
                        }
                        ForEach(viewModel.stateNames, id: \.self) { stateName in
                            CanvasObjectView(
                                viewModel: viewModel.viewModel(forState: stateName).tracker,
                                coordinateSpace: viewModel.coordinateSpace,
                                textRepresentation: viewModel.viewModel(forState: stateName).name
                            ) {
                                StateView(
                                    viewModel: viewModel.viewModel(forState: stateName),
                                    focused: viewModel.selectedObjects.contains(.state(stateIndex: viewModel.viewModel(forState: stateName).index))
                                )
                                .onChange(of: viewModel.viewModel(forState: stateName).expanded) { _ in
//                                        self.viewModel.correctTransitionLocations(for: viewModel.viewModel(for: stateName).state.wrappedValue)
                                }
                            }
//                                .gesture(TapGesture().onEnded { viewModel.addSelectedState(view: self, at: viewModel.viewModel(for: stateName).stateIndex) }.modifiers(.shift))
                                .onTapGesture(count: 2) { edittingState = stateName; focus = .state(stateIndex: viewModel.viewModel(forState: stateName).index) }
                                .onTapGesture {
                                    viewModel.selectedObjects = [.state(stateIndex: viewModel.viewModel(forState: stateName).index)]
                                    focus = .state(stateIndex: viewModel.viewModel(forState: stateName).index)
                                }
//                                .gesture(viewModel.createTransitionGesture(forView: self, forState: viewModel.viewModel(for: stateName).stateIndex))
//                                .gesture(viewModel.dragStateGesture(forView: self, forState: viewModel.viewModel(for: stateName).stateIndex, size: geometry.size))
//                                .onChange(of: viewModel.tracker(for: stateName).expanded) { _ in
//                                    self.viewModel.updateTransitionLocations(source: viewModel.viewModel(for: stateName).state.wrappedValue)
//                                }
                                .contextMenu {
                                    Button("Delete", action: {
                                        viewModel.deleteState(stateName)
                                        viewModel.selectedObjects.remove(.state(stateIndex: viewModel.viewModel(forState: stateName).index))
                                    })
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
