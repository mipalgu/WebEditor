/*
 * CanvasViewModel.swift
 * 
 *
 * Created by Callum McColl on 10/5/21.
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

import TokamakShim
import Machines
import AttributeViews
import Utilities
import GUUI
import swift_helpers

final class CanvasViewModel: ObservableObject {
    
    let machineRef: Ref<Machine>
    
    weak var notifier: GlobalChangeNotifier?
    
    private var stateViewModels: [StateName: StateViewModel]
    
    private var targetTransitions: [StateName: SortedCollection<TransitionTracker>]
    
    private var stateStartPoints: [StateName: CGPoint] = [:]
    
    private var sourceStartPoints: [TransitionTracker: CGPoint] = [:]
    
    private var targetStartPoints: [TransitionTracker: CGPoint] = [:]
    
    private var transitionStartPoints: [TransitionTracker: Curve] = [:]
    
    private var isMoving: Bool = false
    
    let coordinateSpace = "CANVAS_VIEW"
    
    @Published var selectedObjects: Set<ViewType> = []
    @Published var selectedBox: CGRect?
    
    var canvasSize: CGSize = .zero
    
    var machine: Machine {
        get {
            machineRef.value
        } set {
            machineRef.value = newValue
            objectWillChange.send()
        }
    }
    
    var layout: Layout {
        let states = Dictionary<StateName, StateLayout>(uniqueKeysWithValues: machineRef.value.states.map { state in
            let transitions = state.transitions.indices.map {
                self.viewModel(forTransition: $0, attachedToState: state.name).tracker.layout
            }
            let viewModel = self.viewModel(forState: state.name)
            let layout = viewModel.tracker.layout(
                transitions: transitions,
                actions: state.actions.map(\.name),
                bgColor: .init(alpha: 0, red: 0, green: 0, blue: 0),
                editingMode: false,
                stateSelected: false,
                strokeColor: .init(alpha: 0, red: 0, green: 0, blue: 0)
            )
            return (state.name, layout)
        })
        return Layout(states: states)
    }
    
    var stateNames: [StateName] {
        machineRef.value.states.lazy.map(\.name).sorted()
    }
    
    init(machineRef: Ref<Machine>, layout: Layout? = nil, notifier: GlobalChangeNotifier? = nil) {
        self.machineRef = machineRef
        self.notifier = notifier
        let stateViewModels: [StateName: StateViewModel] = Dictionary(uniqueKeysWithValues: layout?.states.compactMap { (stateName, stateLayout) in
            guard let index = machineRef.value.states.firstIndex(where: { $0.name == stateName }) else {
                return nil
            }
            return (stateName, StateViewModel(machine: machineRef, index: index, isText: false, layout: stateLayout, notifier: notifier))
        } ?? [])
        var targetTransitions: [StateName: SortedCollection<TransitionTracker>] = [:]
        stateViewModels.values.forEach { viewModel in
            viewModel.transitions.forEach {
                let transitionViewModel = viewModel.viewModel(forTransition: $0)
                if nil == targetTransitions[transitionViewModel.target] {
                    targetTransitions[transitionViewModel.target] = SortedCollection {
                        if $0.id == $1.id {
                            return .orderedSame
                        }
                        if $0.id < $1.id {
                            return .orderedAscending
                        }
                        return .orderedDescending
                    }
                }
                if targetTransitions[transitionViewModel.target]?.contains(transitionViewModel.tracker) == true {
                    return
                }
                targetTransitions[transitionViewModel.target]?.insert(transitionViewModel.tracker)
            }
        }
        self.stateViewModels = stateViewModels
        self.targetTransitions = targetTransitions
        stateViewModels.values.forEach {
            $0.delegate = self
        }
    }
    
    private func sync() {
        machineRef.value.states.enumerated().forEach {
            let viewModel = viewModel(forState: $1.name)
            viewModel.index = $0
        }
    }
    
    func deleteState(_ stateName: StateName) {
        let viewModel = viewModel(forState: stateName)
        let states = machineRef.value.states
        let result = machineRef.value.deleteState(atIndex: viewModel.index)
        defer { objectWillChange.send() }
        switch result {
        case .failure:
            notifier?.send()
            return
        case .success(true):
            sync()
            notifier?.send()
            return
        default:
            stateViewModels[stateName] = nil
            if viewModel.index + 1 < states.count {
                states[(viewModel.index + 1)..<states.count].forEach {
                    let viewModel = self.viewModel(forState: $0.name)
                    viewModel.index -= 1
                }
            }
            return
        }
    }
    
    func deleteTransition(_ transitionIndex: Int, attachedTo stateName: StateName) {
        let viewModel = viewModel(forState: stateName)
        viewModel.deleteTransition(transitionIndex)
        objectWillChange.send()
    }
    
    func newState() {
        let result = machineRef.value.newState()
        defer { objectWillChange.send() }
        switch result {
        case .success(true), .failure:
            notifier?.send()
        default:
            return
        }
    }
    
    func transitions(forState state: StateName) -> Range<Int> {
        return viewModel(forState: state).transitions
    }
    
    func viewModel(forState state: StateName) -> StateViewModel {
        if let viewModel = stateViewModels[state] {
            return viewModel
        }
        guard let index = machineRef.value.states.firstIndex(where: { $0.name == state }) else {
            fatalError("Unable to fetch state named \(state).")
        }
        let viewModel = StateViewModel(machine: machineRef, index: index)
        viewModel.delegate = self
        stateViewModels[state] = viewModel
        return viewModel
    }
    
    func viewModel(forTransition transitionIndex: Int, attachedToState stateName: StateName) -> TransitionViewModel {
        let stateViewModel = viewModel(forState: stateName)
        return stateViewModel.viewModel(forTransition: transitionIndex)
    }
    
    private func setStateStartPoints(stateName: StateName) {
        stateStartPoints = [:]
        guard let _ = self.machineRef.value.states.first(where: { $0.name == stateName }) else {
            return
        }
        let viewModel = viewModel(forState: stateName)
        stateStartPoints[stateName] = viewModel.tracker.location
    }
    
    private func setTransitionStartCurves() {
        transitionStartPoints = [:]
        machineRef.value.states.forEach { state in
            let name = state.name
            let viewModel = viewModel(forState: name)
            state.transitions.indices.forEach { transitionIndex in
                let tracker = viewModel.viewModel(forTransition: transitionIndex).tracker
                transitionStartPoints[tracker] = tracker.curve
            }
        }
    }
    
    private func setStartPoints(stateName: StateName) {
        setStateStartPoints(stateName: stateName)
        sourceStartPoints = [:]
        targetStartPoints = [:]
        guard let state = self.machineRef.value.states.first(where: { $0.name == stateName }) else {
            return
        }
        let viewModel = viewModel(forState: stateName)
        sourceStartPoints = Dictionary(uniqueKeysWithValues: state.transitions.indices.map {
            let tracker = viewModel.viewModel(forTransition: $0).tracker
            return (tracker, tracker.curve.point0)
        })
        guard let targets = targetTransitions[stateName] else {
            return
        }
        targetStartPoints = Dictionary(uniqueKeysWithValues: targets.map {
            ($0, $0.curve.point3)
        })
    }
    
    private func performMove(for state: StateName, translation: CGSize) {
        guard let start = stateStartPoints[state] else {
            return
        }
        let viewModel = viewModel(forState: state)
        viewModel.tracker.location.x = translation.width + start.x
        viewModel.tracker.location.y = translation.height + start.y
        let sources = sourceStartPoints.keys
        sources.forEach {
            let point = sourceStartPoints[$0]!
            $0.curve.point0.x = point.x + translation.width
            $0.curve.point0.y = point.y + translation.height
        }
        let targets = targetStartPoints.keys
        targets.forEach {
            let point = targetStartPoints[$0]!
            $0.curve.point3.x = point.x + translation.width
            $0.curve.point3.y = point.y + translation.height
        }
    }
    
    private func moveTransition(tracker: TransitionTracker, translation: CGSize, start: Curve) {
        let dx = translation.width
        let dy = translation.height
        tracker.curve.point0.x = dx + start.point0.x
        tracker.curve.point0.y = dy + start.point0.y
        tracker.curve.point1.x = dx + start.point1.x
        tracker.curve.point1.y = dy + start.point1.y
        tracker.curve.point2.x = dx + start.point2.x
        tracker.curve.point2.y = dy + start.point2.y
        tracker.curve.point3.x = dx + start.point3.x
        tracker.curve.point3.y = dy + start.point3.y
    }
    
    func moveState(state: StateName, translation: CGSize) {
        if !isMoving {
            setStartPoints(stateName: state)
            isMoving = true
        }
        performMove(for: state, translation: translation)
    }
    
    func finishMoveState(state: StateName, translation: CGSize) {
        performMove(for: state, translation: translation)
        isMoving = false
    }
    
    private func moveAll(translation: CGSize) {
        machineRef.value.states.forEach { state in
            guard let point = stateStartPoints[state.name] else {
                return
            }
            let viewModel = viewModel(forState: state.name)
            viewModel.tracker.location.x = point.x + translation.width
            viewModel.tracker.location.y = point.y + translation.height
            state.transitions.indices.forEach { transitionIndex in
                let tracker = viewModel.viewModel(forTransition: transitionIndex).tracker
                guard let curve = transitionStartPoints[tracker] else {
                    return
                }
                moveTransition(tracker: tracker, translation: translation, start: curve)
            }
        }
    }
    
    func dragCanvas(translation: CGSize) {
        if !isMoving {
            machineRef.value.states.forEach { state in
                setStateStartPoints(stateName: state.name)
                setTransitionStartCurves()
            }
            isMoving = true
        }
        moveAll(translation: translation)
    }
    
    func finishDragCanvas(translation: CGSize) {
        moveAll(translation: translation)
        isMoving = false
    }
    
}

// MARK: - GlobalChangeNotifier

extension CanvasViewModel: GlobalChangeNotifier {
    
    func send() {
        stateViewModels.values.forEach {
            $0.send()
        }
        objectWillChange.send()
    }
    
}

// MARK: - StateViewModelDelegate

extension CanvasViewModel: StateViewModelDelegate {
    
    func didChangeName(_ viewModel: StateViewModel, from oldName: StateName, to newName: StateName) {
        stateViewModels[newName] = viewModel
        targetTransitions[newName] = targetTransitions[oldName]
        targetTransitions[oldName] = nil
    }
    
    func didChangeTransitionTarget(_ viewModel: StateViewModel, from oldName: StateName, to newName: StateName, transition: TransitionViewModel) {
        targetTransitions[oldName]?.removeAll(transition.tracker)
        if nil == targetTransitions[newName] {
            targetTransitions[newName] = SortedCollection {
                if $0.id == $1.id {
                    return .orderedSame
                }
                if $0.id < $1.id {
                    return .orderedAscending
                }
                return .orderedDescending
            }
        }
        targetTransitions[newName]?.insert(transition.tracker)
    }
    
    func didDeleteTransition(_ viewModel: StateViewModel, transition: TransitionViewModel, targeting targetStateName: StateName) {
        targetTransitions[targetStateName]?.removeAll(transition.tracker)
    }
    
}

// MARK: - Gestures

extension CanvasViewModel {
    
    var selectionBoxGesture: some Gesture {
        return DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpace))
            .modifiers(.shift)
            .onChanged {
                self.selectedBox = CGRect(corner: $0.startLocation, oppositeCorner: $0.location)
            }
            .modifiers(.shift)
            .onEnded {
                let rect = CGRect(corner: $0.startLocation, oppositeCorner: $0.location)
                var selectedStates: Set<ViewType> {
                    if rect.width == 0 || rect.height == 0 {
                        return []
                    }
                    return Set(self.machineRef.value.states.compactMap {
                        let viewModel = self.viewModel(forState: $0.name)
                        let position = viewModel.tracker.location
                        if rect.contains(position) {
                            return ViewType.state(stateIndex: viewModel.index)
                        } else {
                            return nil
                        }
                    })
                }
                var selectedTransitions: Set<ViewType> {
                    if rect.width == 0, rect.height == 0 {
                        return []
                    }
                    return Set(self.machineRef.value.states.flatMap { state in
                        state.transitions.indices.compactMap { transitionIndex in
                            let viewModel = self.viewModel(forTransition: transitionIndex, attachedToState: state.name)
                            let position = viewModel.tracker.location
                            if rect.contains(position) {
                                return ViewType.transition(stateIndex: viewModel.stateIndex, transitionIndex: transitionIndex)
                            } else {
                                return nil
                            }
                        }
                    })
                }
                self.selectedObjects = selectedStates.union(selectedTransitions)
                self.selectedBox = nil
            }
    }
    
}
