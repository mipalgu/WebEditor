//
//  MachineViewModel.swift
//  
//
//  Created by Morgan McColl on 16/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities

public class MachineViewModel: ObservableObject, Dragable {
    
    @Reference public var machine: Machine
    
    @Published var states: [StateViewModel]
    
    public var path: Attributes.Path<Machine, Machine> {
        machine.path
    }
    
    public var name: String {
        machine[keyPath: path.path].name
    }
    
    public var id: UUID {
        machine.id
    }
    
    let gridWidth: CGFloat = 80.0
    
    let gridHeight: CGFloat = 80.0
    
    var isDragging: Bool = false
    
    var startLocations: [CGPoint] = []
    
    public init(machine: Ref<Machine>) {
        self._machine = Reference(reference: machine)
        let statesPath: Attributes.Path<Machine, [Machines.State]> = machine.value.path.states
        let states: [Machines.State] = machine.value[keyPath: statesPath.path]
        self.states = states.indices.map { stateIndex in
            let stateX: CGFloat = 100.0
            let stateY: CGFloat = 100.0 + CGFloat(stateIndex) * 200.0
            return StateViewModel(machine: machine, path: machine.value.path.states[stateIndex], location: CGPoint(x: stateX, y: stateY))
        }
        self.listen(to: $machine)
    }
    
    init(machine: Ref<Machine>, states: [StateViewModel]) {
        self._machine = Reference(reference: machine)
        self.states = states
        self.listen(to: $machine)
    }
    
    public func removeHighlights() {
        states.forEach {
            $0.highlighted = false
        }
    }
    
    func getStateViewModel(stateName: String) -> StateViewModel {
        guard let vm = self.states.first(where: { $0.name == stateName }) else {
            fatalError("Tried to access state view model that didn't exist")
        }
        return vm
    }
    
    func deleteState(stateViewModel: StateViewModel) {
        /*if !stateViewModel.highlighted {
            return
        }*/
        guard let stateIndex = self.states.firstIndex(of: stateViewModel) else {
            return
        }
        do {
            try self.machine.deleteState(atIndex: stateViewModel.stateIndex)
            self.states.remove(at: stateIndex)
        } catch let error {
            print(error)
        }
    }
    
    public func save() {
        do {
            try machine.save()
            let layoutPath = machine.filePath.appendingPathComponent("Layout.plist")
            let pListData = self.toPlist()
            try pListData.write(to: layoutPath, atomically: true, encoding: .utf8)
            let languagePath = machine.filePath.appendingPathComponent("Semantics.json")
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(machine.semantics)
            try jsonData.write(to: languagePath)
        } catch let error {
            print(error, stderr)
        }
    }
    
    func newState() {
        do {
            try machine.newState()
            guard let newStateIndex = machine.states.firstIndex(where: { state in
                nil == states.map { $0.name }.first(where: { state.name == $0 })
            }) else {
                fatalError("Failed to insert new state.")
            }
            states.insert(StateViewModel(machine: $machine, path: machine.path.states[newStateIndex]), at: newStateIndex)
        } catch let error {
            print("Failed to create state")
            print(error, stderr)
        }
    }
    
    func handleDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        if isDragging {
            self.states.indices.forEach {
                states[$0].location = CGPoint(
                    x: startLocations[$0].x + gesture.translation.width,
                    y: startLocations[$0].y + gesture.translation.height
                )
                states[$0].transitionViewModels.forEach {
                    $0.point0 = $0.translate(point: $0.startLocation.0, trans: gesture.translation)
                    $0.point1 = $0.translate(point: $0.startLocation.1, trans: gesture.translation)
                    $0.point2 = $0.translate(point: $0.startLocation.2, trans: gesture.translation)
                    $0.point3 = $0.translate(point: $0.startLocation.3, trans: gesture.translation)
                }
            }
            return
        }
        startLocations = self.states.map {
            $0.transitionViewModels.forEach {ts in
                ts.startLocation = (ts.point0, ts.point1, ts.point2, ts.point3)
            }
            return $0.location
        }
        isDragging = true
    }
    
    func finishDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        handleDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
        isDragging = false
    }
    
}
