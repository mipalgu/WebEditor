/*
 * CanvasViewModel.swift
 * 
 *
 * Created by Callum McColl on 6/5/21.
 * Copyright © 2021 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

import Foundation
import TokamakShim
import Machines
import Utilities
import GUUI

final class CanvasViewModel: ObservableObject {
    
    let notifier: GlobalChangeNotifier?
    
    var cache: ViewCache
    
    var isMoving: Bool = false
    
    var isStateMoving: Bool = false
    
    var machineBinding: Binding<Machine>
    
    var movingSourceTransitions: [CGPoint] = []
    
    var movingState: StateName = ""
    
    var movingTargetTransitions: [StateName: IndexSet] = [:]
    
    var movingTargetPositions: [StateName: [Int: CGPoint]] = [:]
    
    var originalDimensions: (CGFloat, CGFloat) = (0.0, 0.0)
    
    var startLocations: [StateName: CGPoint] = [:]
    
    var transitionStartLocations: [StateName: [Curve]] = [:]
    
    var machine: Machine {
        get {
            machineBinding.wrappedValue
        } set {
            machineBinding.wrappedValue = newValue
        }
    }
    
    private init(machineBinding: Binding<Machine>, cache: ViewCache, notifier: GlobalChangeNotifier?) {
        self.machineBinding = machineBinding
        self.cache = cache
        self.notifier = notifier
    }
    
    convenience init(machine: Binding<Machine>, plist data: String? = nil, notifier: GlobalChangeNotifier? = nil) {
        let cache: ViewCache
        if let data = data {
            cache = ViewCache(machine: machine, plist: data, notifier: notifier)
        } else {
            cache = ViewCache(machine: machine, notifier: notifier)
        }
        self.init(machineBinding: machine, cache: cache, notifier: notifier)
    }
    
    /// Adds a state to the view selected property. This state will show up as highlighted in the view.
    /// - Parameters:
    ///   - view: The view containing the selected property.
    ///   - index: The state index in the machine.
    func addSelectedState(view: CanvasView, at index: Int) {
        addSelected(view: view, focus: .state(stateIndex: index), selected: .state(stateIndex: index))
    }
    
    /// Adds a transition to a views selected property. This transitions will show up as highlighted in the view.
    /// - Parameters:
    ///   - view: The view containing the selected property.
    ///   - state: The source states index  in the machine.
    ///   - index: The transitions index in the machine.
    func addSelectedTransition(view: CanvasView, from state: Int, at index: Int) {
        addSelected(
            view: view,
            focus: .transition(stateIndex: state, transitionIndex: index),
            selected: .transition(stateIndex: state, transitionIndex: index)
        )
    }
    
    /// Clamps a point within a frame boundary with some padding.
    /// - Parameters:
    ///   - point: The point being displaced.
    ///   - frame: The frame dimensions.
    ///   - dx: The x padding.
    ///   - dy: The y padding.
    /// - Returns: The clamped point.
    func clampPosition(point: CGPoint, frame: CGSize, dx: CGFloat = 0.0, dy: CGFloat = 0.0) -> CGPoint {
        var newX: CGFloat = point.x
        var newY: CGFloat = point.y
        if point.x < dx {
            newX = dx
        } else if point.x > frame.width - dx {
            newX = frame.width - dx
        }
        if point.y < dy {
            newY = dy
        } else if point.y > frame.height - dy {
            newY = frame.height - dy
        }
        return CGPoint(x: newX, y: newY)
    }
    
    /// This function moves transitions if their start and end points exist within the state width and height.
    /// - Parameter state: The state that is overlapping with the transitions
    func correctTransitionLocations(for state: Machines.State) {
        let sources = self.cache.trackers(for: state)
        let sourceTracker = self.cache.tracker(for: state)
        let targets = self.cache.transitions(target: state.name).filter {
            $0.value.count > 0
        }
        let targetTrackers = targets.keys.compactMap { (source: StateName) -> (StateName, IndexSet)? in
            let allViewModels: [TransitionViewModel] = self.cache.transitions(source: source)
            let candidates = targets[source]!
            let targetTransitions = IndexSet(allViewModels.indices.filter { candidates.contains(allViewModels[$0]) })
            if targetTransitions.count == 0 {
                return nil
            }
            return (source, targetTransitions)
        }
        sources.indices.forEach {
            let _ = self.cache.updateTracker(
                for: $0,
                in: state,
                point0: sourceTracker.findEdge(point: sources[$0].curve.point0)
            )
        }
        targetTrackers.forEach { tuple in
            let source = tuple.0
            let trackers = self.cache.trackers(for: source)
            trackers.indices.forEach { i in
                if !tuple.1.contains(i) {
                    return
                }
                let _ = self.cache.updateTracker(
                    for: i,
                    in: source,
                    point3: sourceTracker.findEdge(point: trackers[i].curve.point3)
                )
            }
        }
        self.objectWillChange.send()
    }
    
    /// Creates a new state in the machine and updates the view cache.
    func createState() {
        let newStateIndex = machine.states.count
        let result = machineBinding.wrappedValue.newState()
        guard let _ = try? result.get() else {
            return
        }
//        var updatedMachine = machine
//        machineBinding = Binding(get: { updatedMachine }, set: { updatedMachine = $0 })
//        print(machineBinding.states)
//        machineBinding.update()
//        let stateBinding = Binding<Machines.State>(
//            get: {
//                guard self.machineBinding.wrappedValue.states.count > newStateIndex else {
//                    return Machines.State(name: "", actions: [], transitions: [])
//                }
//                return self.machineBinding.wrappedValue.states[newStateIndex]
//            },
//            set: {
//                guard self.machineBinding.wrappedValue.states.count > newStateIndex else {
//                    return
//                }
//                self.machineBinding.wrappedValue.states[newStateIndex] = $0
//            }
//        )
        if !cache.addNewState(stateIndex: newStateIndex, stateName: machineBinding.wrappedValue.states[newStateIndex].name, state: machineBinding.states[newStateIndex]) {
            fatalError("Created state but failed to create view models")
        }
        self.objectWillChange.send()
    }
    
    /// Creates a drag gesture for creating a transition.
    /// - Parameters:
    ///   - view: The view which contains the gesture.
    ///   - index: The source states index.
    /// - Returns: The drag gesture containing the behaviour for creating new transitions. The user drags a state while holding the command key.
    func createTransitionGesture(forView view: CanvasView, forState index: Int) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(view.coordinateSpace))
            .modifiers(.command)
            .onChanged {
                view.creatingCurve = Curve(source: $0.startLocation, target: $0.location)
            }
            .modifiers(.command)
            .onEnded { gesture in
                view.creatingCurve = nil
                guard let targetName = self.findOverlappingState(point: gesture.location) else {
                    return
                }
                let transitionCount = self.machine.states[index].transitions.count
                let result = self.machineBinding.wrappedValue.newTransition(
                    source: self.machine.states[index].name,
                    target: targetName
                )
                guard let _ = try? result.get() else {
                    return
                }
                let result2 = self.machineBinding.wrappedValue.modify(
                    attribute: self.machine.path.states[index].transitions[transitionCount].condition,
                    value: "true"
                )
                guard let _ = try? result2.get() else {
                    return
                }
                guard
                    self.machineBinding.wrappedValue.states[index].transitions.count == transitionCount + 1,
                    self.machine.states.count > index
                else {
                    fatalError("Successfully created transition but it is not available in the state.")
                }
                let transitionBinding: Binding<Transition> = Binding(
                    get: {
                        guard self.machineBinding.wrappedValue.states[index].transitions.count > transitionCount else {
                            return Transition(target: targetName)
                        }
                        return self.machineBinding.wrappedValue.states[index].transitions[transitionCount]
                    },
                    set: {
                        guard self.machineBinding.wrappedValue.states[index].transitions.count > transitionCount else {
                            return
                        }
                        self.machineBinding.wrappedValue.states[index].transitions[transitionCount] = $0
                    }
                )
                if !self.cache.addNewTransition(
                    stateIndex: index,
                    transitionIndex: transitionCount,
                    target: targetName,
                    startLocation: gesture.startLocation,
                    endLocation: gesture.location,
                    transitionBinding: transitionBinding
                ) {
                    fatalError("Created transition but couldn't create view models.")
                }
                self.objectWillChange.send()
            }
    }
    
    /// Deletes views in the selected property of a parent view. This change also mutates the view cache to remove the view model and tracker for that view.
    /// - Parameter view: The view containing the selected property.
    func deleteSelected(_ view: CanvasView) {
        let stateIndexes = stateIndexes(from: view.selectedObjects)
        let result = machineBinding.wrappedValue.delete(states: stateIndexes)
        guard let _ = try? result.get() else {
            print(machine.errorBag.allErrors.description)
            return
        }
        let stateNames = states(from: view.selectedObjects).map(\.name)
        let _ = cache.deleteStates(names: stateNames)
        view.selectedObjects = []
        view.focus = .machine
        self.objectWillChange.send()
    }
    
    /// Safely deletes a state from a machine while updating the view cache. Also updates the focused property of the view.
    /// - Parameters:
    ///   - view: The view containing the current selected items.
    ///   - index: The index of the state in the machine.
    func deleteState(view: CanvasView, at index: Int) {
        let name = machine.states[index].name
        let result = machineBinding.wrappedValue.deleteState(atIndex: index)
        guard let _ = try? result.get() else {
            print(machine.errorBag.errors(includingDescendantsForPath: machine.path.states[index]))
            return
        }
        let _ = cache.deleteState(name: name)
        removeViewFocus(view: view, focus: .state(stateIndex: index), selected: .state(stateIndex: index))
        self.objectWillChange.send()
    }
    
    func deleteTransition(view: CanvasView, for stateIndex: Int, at transitionIndex: Int) {
        guard machine.states.count > stateIndex else {
            return
        }
        let stateName = machine.states[stateIndex].name
        let result = machineBinding.wrappedValue.deleteTransition(atIndex: transitionIndex, attachedTo: stateName)
        guard let _ = try? result.get() else {
            return
        }
        let _ = cache.deleteTransition(from: stateName, at: transitionIndex)
        removeViewFocus(
            view: view,
            focus: .transition(stateIndex: stateIndex, transitionIndex: transitionIndex),
            selected: .transition(stateIndex: stateIndex, transitionIndex: transitionIndex)
        )
        self.objectWillChange.send()
    }
    
    func dragCanvasGesture(coordinateSpace: String, size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpace))
            .onChanged {
                self.moveElements(gesture: $0, frame: size)
                self.objectWillChange.send()
            }.onEnded {
                self.finishMoveElements(gesture: $0, frame: size)
                self.objectWillChange.send()
            }
    }
    
    func dragStateGesture(forView view: CanvasView, forState index: Int, size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(view.coordinateSpace))
            .onChanged {
                self.cache.handleDrag(for: self.machine.states[index], gesture: $0, frame: size)
                let tracker = self.cache.tracker(for: self.machine.states[index])
                if !tracker.isStretchingX && !tracker.isStretchingY {
                    self.moveTransitions(state: self.machine.states[index].name, gesture: $0, frame: size)
                } else {
                    self.stretchTransitions(state: self.machine.states[index].name)
                }
                self.objectWillChange.send()
            }.onEnded {
                self.finishMovingTransitions()
                self.cache.finishDrag(for: self.machine.states[index], gesture: $0, frame: size)
                self.objectWillChange.send()
            }
    }
    
    func finishMoveElements(gesture: DragGesture.Value, frame: CGSize) {
        moveElements(gesture: gesture, frame: frame)
        isMoving = false
        self.objectWillChange.send()
    }
    
    func selectAll(_ view: CanvasView) {
        view.selectedObjects = Set(
            machine.states.indices.map {
                ViewType.state(stateIndex: $0)
            } +
            machine.states.indices.flatMap { stateIndex in
                machine.states[stateIndex].transitions.indices.map { transitionIndex in
                    ViewType.transition(stateIndex: stateIndex, transitionIndex: transitionIndex)
                }
            }
        )
    }
    
    /// Creates a gesture for dragging a selection box.
    /// - Parameter view: The view using the gesture.
    /// - Returns: The gesture.
    func selectionBoxGesture(forView view: CanvasView) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(view.coordinateSpace))
            .modifiers(.shift)
            .onChanged {
                view.selectedBox = ($0.startLocation, $0.location)
            }
            .modifiers(.shift)
            .onEnded {
                view.selectedObjects = self.findObjectsInSelection(corner0: $0.startLocation, corner1: $0.location)
                view.selectedBox = nil
            }
    }
    
    func straighten(state: StateName, transitionIndex: Int) {
        let tracker = cache.tracker(for: transitionIndex, originating: state)
        if !cache.updateTracker(
            for: transitionIndex,
            in: state,
            newTracker: TransitionTracker(
                source: tracker.curve.point0,
                target: tracker.curve.point3
            )
        ) { return }
        self.objectWillChange.send()
    }
    
    func tracker(for state: StateName) -> StateTracker {
        self.cache.tracker(for: state)
    }
    
    func tracker(for transition: Int, originating from: StateName) -> TransitionTracker {
        self.cache.tracker(for: transition, originating: from)
    }
    
    func transition(for transition: Int, in state: StateName) -> TransitionViewModel {
        self.cache.viewModel(for: transition, originating: state)
    }
    
    func updateTransitionLocations(source: Machines.State) {
        updateTransitionsSources(source: source)
        updateTransitionsTargets(source: source)
        self.objectWillChange.send()
    }
    
    func viewModel(for stateName: StateName) -> StateViewModel {
        self.cache.viewModel(for: stateName)
    }
    
    private func addSelected(view: CanvasView, focus: Focus, selected: ViewType) {
        view.selectedObjects.insert(selected)
        if view.selectedObjects.count == 1 {
            view.focus = focus
            return
        }
        view.focus = .machine
    }
    
    private func displaceTransitions(sourceTransitions: [CGPoint], targetTransitions: [StateName: IndexSet], dS: CGSize, frame: CGSize, source: StateName) {
        guard let state = machine.states.first(where: { $0.name == source }) else {
            return
        }
        sourceTransitions.indices.forEach {
            let newX = min(max(0, sourceTransitions[$0].x + dS.width), frame.width)
            let newY = min(max(0, sourceTransitions[$0].y + dS.height), frame.height)
            let point = CGPoint(x: newX, y: newY)
            if !self.cache.updateTracker(for: $0, in: state, point0: point) {
                fatalError("Cannot move transition")
            }
        }
        targetTransitions.keys.forEach { target in
            let validIndexes = targetTransitions[target]!
            guard let stateIndex = machine.states.firstIndex(where: { $0.name == target }) else {
                return
            }
            let transitions = machine.states[stateIndex].transitions
            guard
                let trackers = transitionStartLocations[target],
                trackers.count >= transitions.count
            else {
                fatalError("No trackers for moving transitions")
            }
            transitions.indices.forEach {
                if !validIndexes.contains($0) {
                    return
                }
                let sourceState = machine.states[stateIndex]
                let newX = min(max(0, trackers[$0].point3.x + dS.width), frame.width)
                let newY = min(max(0, trackers[$0].point3.y + dS.height), frame.height)
                let point = CGPoint(x: newX, y: newY)
                if !self.cache.updateTracker(for: $0, in: sourceState, point3: point) {
                    fatalError("Cannot move transition")
                }
            }
        }
    }
    
    private func findMovingTransitions(state: StateName) -> ([CGPoint], [StateName: IndexSet]) {
        movingState = state
        transitionStartLocations = [:]
        let movingSources = self.cache.trackers(for: state).map(\.curve.point0)
        let movingTargets = self.cache.transitions(target: state).filter {
            $0.value.count > 0
        }
        var movingIndices: [StateName: IndexSet] = [:]
        movingTargets.keys.forEach { sourceName in
            let candidates = movingTargets[sourceName]!
            let transitions = self.cache.transitions(source: sourceName)
            let trackers = self.cache.trackers(for: sourceName)
            transitionStartLocations[sourceName] = trackers.map(\.curve)
            movingIndices[sourceName] = IndexSet(transitions.indices.filter { index in
                candidates.contains(transitions[index])
            })
        }
        return (movingSources, movingIndices)
    }
    
    
    /// Finds all the views within the selection box.
    /// - Parameters:
    ///   - corner0: A corner of the selection box.
    ///   - corner1: The second corner of the selection box (opposite to corner0).
    /// - Returns: A set of ViewTypes signifying the views within the selection box.
    private func findObjectsInSelection(corner0: CGPoint, corner1: CGPoint) -> Set<ViewType> {
        findSelectedStates(corner0: corner0, corner1: corner1).union(findSelectedTransitions(corner0: corner0, corner1: corner1))
    }
        
    private func findOverlappingState(point: CGPoint) -> StateName? {
        self.cache.overlappingState(point: point)
    }
    
    
    /// Finds the states within the selection box.
    /// - Parameters:
    ///   - corner0: A corner of the selection box.
    ///   - corner1: The second corner of the selection box (opposite to corner0).
    /// - Returns: A set of ViewTypes signifying the states within the selection box.
    private func findSelectedStates(corner0: CGPoint, corner1: CGPoint) -> Set<ViewType> {
        let allStates = machine.states
        let focusedStates = allStates.indices.filter {
            let position =  self.cache.tracker(for: allStates[$0]).location
            return isWithinBound(corner0: corner0, corner1: corner1, position: position)
        }.map { ViewType.state(stateIndex: $0) }
        return Set(focusedStates)
    }
    
    
    /// Finds the transitions within the selection box.
    /// - Parameters:
    ///   - corner0: A corner of the selection box.
    ///   - corner1: The second corner of the selection box (opposite to corner0).
    /// - Returns: A set of ViewTypes signifying the transitions within the selection box.
    private func findSelectedTransitions(corner0: CGPoint, corner1: CGPoint) -> Set<ViewType> {
        let allStates = machine.states
        var focusedTransitions: [ViewType] = []
        allStates.indices.forEach { stateIndex in
            let trackers = self.cache.trackers(for: allStates[stateIndex])
            focusedTransitions.append(
                contentsOf: trackers.indices.filter { index in
                    let position = trackers[index].location
                    return isWithinBound(corner0: corner0, corner1: corner1, position: position)
                }.map {
                    ViewType.transition(stateIndex: stateIndex, transitionIndex: $0)
                }
            )
        }
        return Set(focusedTransitions)
    }
    
    private func finishMovingTransitions() {
        isStateMoving = false
    }
    
    private func isWithinBound(corner0: CGPoint, corner1: CGPoint, position: CGPoint) -> Bool {
        position.x >= min(corner0.x, corner1.x) &&
            position.x <= max(corner0.x, corner1.x) &&
            position.y >= min(corner0.y, corner1.y) &&
            position.y <= max(corner0.y, corner1.y)
    }
    
    private func moveElements(gesture: DragGesture.Value, frame: CGSize) {
        if isMoving {
            let stateNames = machine.states.map(\.name)
            stateNames.forEach {
                moveState(stateName: $0, gesture: gesture, frame: frame)
            }
            transitionStartLocations.keys.forEach { name in
                let trackers = self.cache.trackers(for: name)
                trackers.indices.forEach {
                    moveTransition(state: name, transitionIndex: $0, gesture: gesture)
                }
            }
            return
        }
        startMoving()
    }
    
    private func moveState(stateName: StateName, gesture: DragGesture.Value, frame: CGSize) {
        let newX = startLocations[stateName]!.x - gesture.translation.width
        let newY = startLocations[stateName]!.y - gesture.translation.height
        let _ = self.cache.updateTracker(for: stateName, newLocation: CGPoint(x: newX, y: newY))
        let _ = self.cache.updateTracker(for: stateName, isText: newX > frame.width || newY > frame.height || newX < 0.0 || newY < 0.0)
    }
    
    private func moveTransition(state name: StateName, transitionIndex: Int, gesture: DragGesture.Value) {
        let x0 = transitionStartLocations[name]![transitionIndex].point0.x - gesture.translation.width
        let y0 = transitionStartLocations[name]![transitionIndex].point0.y - gesture.translation.height
        let x1 = transitionStartLocations[name]![transitionIndex].point1.x - gesture.translation.width
        let y1 = transitionStartLocations[name]![transitionIndex].point1.y - gesture.translation.height
        let x2 = transitionStartLocations[name]![transitionIndex].point2.x - gesture.translation.width
        let y2 = transitionStartLocations[name]![transitionIndex].point2.y - gesture.translation.height
        let x3 = transitionStartLocations[name]![transitionIndex].point3.x - gesture.translation.width
        let y3 = transitionStartLocations[name]![transitionIndex].point3.y - gesture.translation.height
        let curve = Curve(
            point0: CGPoint(x: x0, y: y0),
            point1: CGPoint(x: x1, y: y1),
            point2: CGPoint(x: x2, y: y2),
            point3: CGPoint(x: x3, y: y3)
        )
        guard self.cache.updateTracker(for: transitionIndex, in: name, curve: curve) else {
            fatalError("Can't update transition \(transitionIndex) in state \(name)")
        }
    }
    
    private func moveTransitions(state: StateName, gesture: DragGesture.Value, frame: CGSize) {
        if !isStateMoving {
            isStateMoving = true
            let effected = findMovingTransitions(state: state)
            movingSourceTransitions = effected.0
            movingTargetTransitions = effected.1
            return
        }
        displaceTransitions(sourceTransitions: movingSourceTransitions, targetTransitions: movingTargetTransitions, dS: gesture.translation, frame: frame, source: movingState)
    }
    
    private func newStateViewModel(stateIndex: Int) -> StateViewModel {
        StateViewModel(
            machine: machineBinding,
            path: machine.path.states[stateIndex],
            state: machineBinding.states[stateIndex],
            stateIndex: stateIndex,
            notifier: notifier
        )
    }
    
    private func removeViewFocus(view: CanvasView, focus: Focus, selected: ViewType) {
        if view.focus == focus {
            view.focus = .machine
        }
        if view.selectedObjects.contains(selected) {
            view.selectedObjects.remove(selected)
        }
    }
    
    private func setTargetPositions() {
        movingTargetPositions = [:]
        movingTargetTransitions.keys.forEach { source in
            guard
                let candidates = movingTargetTransitions[source],
                let stateIndex = machine.states.firstIndex(where: { $0.name == source })
            else {
                return
            }
            let transitions = machine.states[stateIndex].transitions
            var tempDict: [Int: CGPoint] = [:]
            transitions.indices.forEach {
                if !candidates.contains($0) {
                    return
                }
                tempDict[$0] = self.cache.tracker(for: $0, originating: source).curve.point3
            }
            movingTargetPositions[source] = tempDict
        }
    }
    
    private func startMoving() {
        machine.states.map(\.name).forEach {
            startLocations[$0] = self.cache.tracker(for: $0).location
            transitionStartLocations[$0] = self.cache.trackers(for: $0).map(\.curve)
        }
        isMoving = true
    }
    
    private func stateIndexes(from views: Set<ViewType>) -> IndexSet {
        IndexSet(machine.states.indices.compactMap {
            if views.contains(.state(stateIndex: $0)) {
                return $0
            }
            return nil
        })
    }
    
    private func states(from views: Set<ViewType>) -> [Machines.State] {
        machine.states.indices.compactMap {
            if views.contains(.state(stateIndex: $0)) {
                return machine.states[$0]
            }
            return nil
        }
    }
    
    private func stretchTransitions(state: StateName) {
        let model = self.cache.tracker(for: state)
        if !isStateMoving {
            isStateMoving = true
            let effected = findMovingTransitions(state: state)
            movingSourceTransitions = effected.0
            movingTargetTransitions = effected.1
            originalDimensions = (model.width, model.height)
            setTargetPositions()
            return
        }
        movingSourceTransitions.indices.forEach {
            guard let movingStateObj = machine.states.first(where: { $0.name == movingState }) else {
                return
            }
            let x = movingSourceTransitions[$0].x
            let y = movingSourceTransitions[$0].y
            let relativeX = x - model.location.x
            let relativeY = y - model.location.y
            let dx = (model.width - originalDimensions.0) / 2.0
            let dy = (model.height - originalDimensions.1) / 2.0
            let newX = relativeX < 0 ? x - dx : x + dx
            let newY = relativeY < 0 ? y - dy : y + dy
            let point = CGPoint(x: newX, y: newY)
            let _ = self.cache.updateTracker(for: $0, in: movingStateObj, point0: point)
        }
        movingTargetTransitions.keys.forEach { source in
            guard let stateIndex = machine.states.firstIndex(where: { $0.name == source }) else {
                return
            }
            let candidates = movingTargetTransitions[source]!
            self.machine.states[stateIndex].transitions.indices.forEach {
                if !candidates.contains($0) {
                    return
                }
                let stateObj = self.machine.states[stateIndex]
                guard
                    let x = movingTargetPositions[source]?[$0]?.x,
                    let y = movingTargetPositions[source]?[$0]?.y
                else {
                    return
                }
                let relativeX = x - model.location.x
                let relativeY = y - model.location.y
                let dx = (model.width - originalDimensions.0) / 2.0
                let dy = (model.height - originalDimensions.1) / 2.0
                let newX = relativeX < 0 ? x - dx : x + dx
                let newY = relativeY < 0 ? y - dy : y + dy
                let point = CGPoint(x: newX, y: newY)
                let _ = self.cache.updateTracker(for: $0, in: stateObj, point3: point)
            }
        }
    }
    
    private func transitionIndexes(from views: Set<ViewType>) -> [StateName: IndexSet] {
        var temp: [StateName: IndexSet] = [:]
        machine.states.indices.forEach { stateIndex in
            temp[machine.states[stateIndex].name] = IndexSet(machine.states[stateIndex].transitions.indices.compactMap { transitionIndex in
                if views.contains(.transition(stateIndex: stateIndex, transitionIndex: transitionIndex)) {
                    return transitionIndex
                }
                return nil
            })
        }
        return temp
    }
    
    private func updateTransitionsSources(source: Machines.State) {
        let sourceTracker = self.cache.tracker(for: source.name)
        source.transitions.indices.forEach {
            let existingViewModel = self.cache.tracker(for: $0, originating: source)
            let targetTracker = self.cache.tracker(for: source.transitions[$0].target)
            let _ = self.cache.updateTracker(
                for: $0,
                in: source,
                newTracker: TransitionTracker(
                    source: sourceTracker,
                    sourcePoint: existingViewModel.curve.point0,
                    target: targetTracker,
                    targetPoint: existingViewModel.curve.point3
                )
            )
        }
    }
    
    private func updateTransitionsTargets(source: Machines.State) {
        guard let _ = machine.states.firstIndex(where: { $0 == source }) else {
            return
        }
        let targets = findMovingTransitions(state: source.name).1
        targets.keys.forEach { name in
            guard let stateIndex = machine.states.firstIndex(where: { $0.name == name }) else {
                return
            }
            let state = machine.states[stateIndex]
            let candidates = targets[name]!
            machine.states[stateIndex].transitions.indices.forEach {
                if !candidates.contains($0) {
                    return
                }
                let existingTracker = self.cache.tracker(for: $0, originating: state.name)
                let targetName = state.transitions[$0].target
                let sourceTracker = self.cache.tracker(for: state.name)
                let targetTracker = self.cache.tracker(for: targetName)
                let _ = self.cache.updateTracker(
                    for: $0,
                    in: state.name,
                    newTracker: TransitionTracker(
                        source: sourceTracker,
                        sourcePoint: existingTracker.curve.point0,
                        target: targetTracker,
                        targetPoint: existingTracker.curve.point3
                    )
                )
            }
        }
    }
    
}

//PLIST EXTENSION
extension CanvasViewModel {
    
    var plist: String {
        self.cache.plist
    }
    
}
