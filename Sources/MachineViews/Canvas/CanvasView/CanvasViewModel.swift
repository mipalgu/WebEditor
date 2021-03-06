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
import MetaMachines
import AttributeViews
import Utilities
import GUUI
import swift_helpers

protocol CanvasViewModelDelegate: AnyObject {
    
    func didChangeFocus(_ viewModel: CanvasViewModel)
    
    func layoutDidChange(_: CanvasViewModel, layout: Layout)
    
}

final class CanvasViewModel: ObservableObject {
    
    weak var delegate: CanvasViewModelDelegate?
    
    let machineRef: Ref<MetaMachine>
    
    let focusRef: Ref<Focus>
    
    weak var notifier: GlobalChangeNotifier?
    
    private var stateViewModels: [StateName: StateViewModel]
    
    private var targetTransitions: [StateName: SortedCollection<TransitionTracker>]
    
    private var stateDragTransaction: StateDragTransaction! = nil
    
    let coordinateSpace = "CANVAS_VIEW"
    
    var creatingCurve: Curve? = nil
    
    @Published var edittingState: StateName? = nil
    
    @Published var selectedObjects: Set<ViewType> = []
    @Published var selectedBox: CGRect?
    
    var canvasSize: CGSize = .zero
    
    var hasTransitions: Bool {
        selectedObjects.first(where: \.isTransition) != nil
    }
    
    var machine: MetaMachine {
        get {
            machineRef.value
        } set {
            machineRef.value = newValue
            objectWillChange.send()
        }
    }
    
    var focus: Focus {
        get {
            focusRef.value
        } set {
            focusRef.value = newValue
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
    
    init(machineRef: Ref<MetaMachine>, focusRef: Ref<Focus>, layout: Layout? = nil, notifier: GlobalChangeNotifier? = nil) {
        self.machineRef = machineRef
        self.focusRef = focusRef
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
    
    func transitions(forState state: StateName) -> Range<Int> {
        return viewModel(forState: state).transitions
    }
    
    func targetTransitionTrackers(forState state: StateName) -> [TransitionTracker] {
        return targetTransitions[state].map { Array($0) } ?? []
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

    
}

// MARK: - Transition Operations

extension CanvasViewModel {
    
    func straighten(stateName: StateName, transitionIndex: Int) {
        guard let state = machine.states.first(where: { $0.name == stateName }) else {
            return
        }
        let sourceViewModel = viewModel(forState: stateName)
        let targetTracker = viewModel(forState: state.transitions[transitionIndex].target).tracker
        let newTracker = TransitionTracker(source: sourceViewModel.tracker, target: targetTracker)
        sourceViewModel.viewModel(forTransition: transitionIndex).tracker.curve = newTracker.curve
        delegate?.layoutDidChange(self, layout: self.layout)
    }
    
}

// MARK: - Selection Management

extension CanvasViewModel {
    
    func deleteSelected() {
        let sorted = selectedObjects.sorted { (lhs, _) in
            lhs.isTransition
        }
        let firstStateIndex = sorted.firstIndex(where: \.isState)
        let states = IndexSet((firstStateIndex == nil ? [] : sorted[firstStateIndex!..<sorted.count]).map(\.stateIndex))
        let transitionViewTypes = sorted[0..<(firstStateIndex ?? sorted.count)]
        let transitions: [StateName: IndexSet] = Dictionary(uniqueKeysWithValues: transitionViewTypes.sorted {
            $0.stateIndex < $1.stateIndex
        }.lazy.grouped {
            $0.stateIndex == $1.stateIndex
        }.compactMap {
            if $0.isEmpty, machineRef.value.states.count <= $0[0].stateIndex {
                return nil
            }
            return (machineRef.value.states[$0[0].stateIndex].name, IndexSet($0.map { $0.transitionIndex }))
        })
        transitions.forEach {
            deleteTransitions($1, attachedTo: $0)
        }
        deleteStates(states)
        selectedObjects = []
        objectWillChange.send()
    }
    
    func selectAll() {
        machine.states.indices.forEach { stateIndex in
            let stateViewType = ViewType.state(stateIndex: stateIndex)
            selectedObjects.insert(stateViewType)
            machine.states[stateIndex].transitions.indices.forEach {
                let transitionViewType = ViewType.transition(stateIndex: stateIndex, transitionIndex: $0)
                selectedObjects.insert(transitionViewType)
            }
        }
    }
    
    func straightenSelected() {
        selectedObjects.lazy.filter(\.isTransition).forEach {
            let name = machine.states[$0.stateIndex].name
            straighten(stateName: name, transitionIndex: $0.transitionIndex)
        }
    }
    
}

// MARK: - CRUD Operations

extension CanvasViewModel {
    
    func deleteState(_ stateName: StateName) {
        guard let stateIndex = machineRef.value.states.firstIndex(where: { $0.name == stateName }) else {
            return
        }
        let viewType = ViewType.state(stateIndex: stateIndex)
        selectedObjects.remove(viewType)
        if let editState = edittingState {
            if editState == stateName {
                edittingState = nil
            }
        }
        let viewModel = viewModel(forState: stateName)
        let states = machineRef.value.states
        let result = machineRef.value.deleteState(atIndex: viewModel.index)
        defer { objectWillChange.send() }
        switch result {
        case .failure:
            notifier?.send()
            return
        case .success(let notify):
            defer {
                machineRef.value.states.forEach {
                    let viewModel = self.viewModel(forState: $0.name)
                    viewModel.removeTransitionViewModels(targeting: stateName)
                }
                selectedObjects = []
            }
            if notify {
                sync()
                notifier?.send()
                return
            }
            stateViewModels[stateName] = nil
            if viewModel.index + 1 < states.count {
                states[(viewModel.index + 1)..<states.count].forEach {
                    let viewModel = self.viewModel(forState: $0.name)
                    viewModel.index -= 1
                }
            }
        }
    }
    
    private func deleteStates(_ states: IndexSet) {
        // Delete States from machine
        let stateIndices = machineRef.value.states.indices
        let stateNames = Dictionary(uniqueKeysWithValues: stateIndices.map {
            ($0, machineRef.value.states[$0].name)
        })
        let viewModels: [Int: StateViewModel] = stateNames.mapValues { self.viewModel(forState: $0) }
        let stateCounts = Dictionary(uniqueKeysWithValues: machineRef.value.states.map {
            ($0.name, $0.transitions.count)
        })
        let deletingTransitions: [StateName: IndexSet] = Dictionary(uniqueKeysWithValues: machineRef.value.states.compactMap { state in
            let viewModel = self.viewModel(forState: state.name)
            if states.contains(viewModel.index) {
                return nil
            }
            let transitions: [Int] = viewModel.transitions.compactMap {
                let transitionViewModel = self.viewModel(forTransition: $0, attachedToState: state.name)
                let targetViewModel = self.viewModel(forState: transitionViewModel.target)
                return states.contains(targetViewModel.index) ? transitionViewModel.transitionIndex : nil
            }
            return transitions.isEmpty ? nil : (state.name, IndexSet(transitions))
        })
        let result = machineRef.value.delete(states: states)
        defer { objectWillChange.send() }
        switch result {
        case .failure:
            notifier?.send()
            return
        case .success(let notify):
            defer {
                if notify { notifier?.send() }
            }
            deletingTransitions.forEach {
                guard let count = stateCounts[$0] else {
                    return
                }
                self.viewModel(forState: $0).removeTransitionViewModels(atOffsets: $1, countBeforeDeletion: count)
            }
            var indexes = Array(stateIndices)
            indexes.remove(atOffsets: states) { (index, nextIndex, previouslyDeleted) in
                ((index + 1)..<nextIndex).forEach { currentIndex in
                    guard let viewModel = viewModels[currentIndex] else {
                        return
                    }
                    viewModel.index -= previouslyDeleted
                }
            }
        }
    }
    
    func deleteTransition(_ transitionIndex: Int, attachedTo stateName: StateName) {
        let viewType = viewType(stateName: stateName, transitionIndex: transitionIndex)
        selectedObjects.remove(viewType)
        let viewModel = viewModel(forState: stateName)
        viewModel.deleteTransition(transitionIndex)
        objectWillChange.send()
    }
    
    func deleteTransitions(_ transitions: IndexSet, attachedTo stateName: StateName) {
        let viewModel = viewModel(forState: stateName)
        viewModel.deleteTransitions(in: transitions)
        self.objectWillChange.send()
    }
    
    func newState() {
        let result = machineRef.value.newState()
        defer {
            changeLayout()
            objectWillChange.send()
        }
        switch result {
        case .success(true), .failure:
            notifier?.send()
            guard machineRef.value.states.count > 0 else {
                return
            }
            let stateIndex = machineRef.value.states.count - 1
            stateViewModels[machineRef.value.states[stateIndex].name] = StateViewModel(machine: machineRef, index: stateIndex)
            
        default:
            return
        }
    }
    
    func newTransition(source: MetaMachines.State, target: MetaMachines.State, suggested shape: Curve) {
        let result = machineRef.value.newTransition(source: source.name, target: target.name, condition: "")
        guard let _ = try? result.get() else {
            return
        }
        let stateViewModel = viewModel(forState: source.name)
        stateViewModel.viewModel(forTransition: source.transitions.count).tracker.curve = shape
        delegate?.layoutDidChange(self, layout: self.layout)
        self.objectWillChange.send()
    }
    
    private func sync() {
        machineRef.value.states.enumerated().forEach {
            let viewModel = viewModel(forState: $1.name)
            viewModel.index = $0
        }
    }
    
    private func viewType(stateName: StateName, transitionIndex: Int?) -> ViewType {
        guard let stateIndex = machine.states.firstIndex(where: { $0.name == stateName }) else {
            fatalError("Couldn't find state called \(stateName)")
        }
        guard let index = transitionIndex else {
            return ViewType.state(stateIndex: stateIndex)
        }
        return ViewType.transition(stateIndex: stateIndex, transitionIndex: index)
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
    
    func didChangeExpanded(_ viewModel: StateViewModel, from old: Bool, to new: Bool) {
        if old == new {
            return
        }
        let name = viewModel.name
        guard let state = machine.states.first(where: { $0.name == viewModel.name }) else {
            return
        }
        state.transitions.indices.forEach {
            let targetTracker = self.viewModel(forState: state.transitions[$0].target).tracker
            viewModel.viewModel(forTransition: $0).tracker.rectifyCurve(sourceTracker: viewModel.tracker, targetTracker: targetTracker)
        }
        machine.states.forEach { state in
            if state.name == name {
                return
            }
            let sourceViewModel = self.viewModel(forState: state.name)
            let sourceTracker = sourceViewModel.tracker
            state.transitions.indices.forEach {
                let target = state.transitions[$0].target
                if target != name {
                    return
                }
                let targetTracker = self.viewModel(forState: target).tracker
                sourceViewModel.viewModel(forTransition: $0).tracker.rectifyCurve(sourceTracker: sourceTracker, targetTracker: targetTracker)
            }
        }
        changeLayout()
    }
    
    func didChangeName(_ viewModel: StateViewModel, from oldName: StateName, to newName: StateName) {
        stateViewModels[newName] = viewModel
        stateViewModels[oldName] = nil
        targetTransitions[newName] = targetTransitions[oldName]
        targetTransitions[oldName] = nil
        changeLayout()
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
        changeLayout()
    }
    
    func didDeleteTransition(_ viewModel: StateViewModel, transition: TransitionViewModel, targeting targetStateName: StateName) {
        targetTransitions[targetStateName]?.removeAll(transition.tracker)
        changeLayout()
    }
    
    func layoutDidChange(_ viewModel: StateViewModel) {
        changeLayout()
    }
    
    private func changeLayout() {
        guard let delegate = self.delegate else {
            return
        }
        delegate.layoutDidChange(self, layout: self.layout)
    }
    
}

// MARK: - Gestures

extension CanvasViewModel {
    
    var clearEdittingStateGesture: some Gesture {
        TapGesture(count: 2).onEnded {
            self.edittingState = nil
            self.focus = .machine
            self.delegate?.didChangeFocus(self)
        }
    }
    
    var clearSelectionGesture: some Gesture {
        TapGesture().onEnded {
            self.selectedObjects = []
            self.focus = .machine
            self.delegate?.didChangeFocus(self)
        }
    }
    
    var createTransitionGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpace))
            .onChanged {
                self.creatingCurve = Curve(source: $0.startLocation, target: $0.location)
                self.objectWillChange.send()
            }
            .onEnded { gesture in
                self.creatingCurve = nil
                guard
                    let sourceState = self.machine.states.first(where: { self.viewModel(forState: $0.name).tracker.isWithin(point: gesture.startLocation) }),
                    let targetState = self.machine.states.first(where: { self.viewModel(forState: $0.name).tracker.isWithin(point: gesture.location) })
                else {
                    self.objectWillChange.send()
                    return
                }
                let tracker = TransitionTracker(
                    source: self.viewModel(forState: sourceState.name).tracker,
                    sourcePoint: gesture.startLocation,
                    target: self.viewModel(forState: targetState.name).tracker,
                    targetPoint: gesture.location
                )
                self.newTransition(source: sourceState, target: targetState, suggested: tracker.curve)
            }
            .modifiers(.command)
    }
    
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
    
    func addStateToSelectionGesture(state stateName: StateName) -> some Gesture {
        TapGesture().onEnded {
            self.selectedObjects.insert(.state(stateIndex: self.viewModel(forState: stateName).index))
            if self.selectedObjects.count > 1 {
                self.focus = .machine
            } else {
                self.focus = .state(stateIndex: self.viewModel(forState: stateName).index)
            }
            self.delegate?.didChangeFocus(self)
        }.modifiers(.shift)
    }
    
    func addTransitionToSelectionGesture(transition transitionIndex: Int, state stateName: StateName) -> some Gesture {
        TapGesture().onEnded {
            self.selectedObjects.insert(.transition(stateIndex: self.viewModel(forState: stateName).index, transitionIndex: transitionIndex))
            if self.selectedObjects.count > 1 {
                self.focus = .machine
            } else {
                self.focus = .transition(stateIndex: self.viewModel(forState: stateName).index, transitionIndex: transitionIndex)
            }
            self.delegate?.didChangeFocus(self)
        }.modifiers(.shift)
    }
    
    func dragCanvasGesture(bounds: CGSize) -> some Gesture {
        var transaction: CanvasDragTransaction! = nil
        return DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpace))
            .onChanged {
                if transaction == nil {
                    transaction = CanvasDragTransaction(viewModel: self)
                }
                transaction.move(by: $0.translation, bounds: bounds)
            }.onEnded {
                if transaction == nil {
                    transaction = CanvasDragTransaction(viewModel: self)
                }
                transaction.move(by: $0.translation, bounds: bounds)
                transaction.finish()
                transaction = nil
            }
    }
    
    func dragStateGesture(stateName: StateName, bounds: CGSize) -> _EndedGesture<_ChangedGesture<DragGesture>> {
        return DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpace))
            .onChanged {
                if self.stateDragTransaction == nil {
                    self.stateDragTransaction = StateDragTransaction(viewModel: self, stateName: stateName)
                }
                self.stateDragTransaction.drag(by: $0, bounds: bounds)
            }.onEnded {
                if self.stateDragTransaction == nil {
                    self.stateDragTransaction = StateDragTransaction(viewModel: self, stateName: stateName)
                }
                self.stateDragTransaction.finish(by: $0, bounds: bounds)
                self.stateDragTransaction = nil
            }
    }
    
    func makeStateSelectionGesture(state stateName: StateName) -> some Gesture {
        TapGesture().onEnded {
            self.selectedObjects = [.state(stateIndex: self.viewModel(forState: stateName).index)]
            self.focus = .state(stateIndex: self.viewModel(forState: stateName).index)
            self.delegate?.didChangeFocus(self)
        }
    }
    
    func makeTransitionSelectionGesture(transition transitionIndex: Int, state stateName: StateName) -> some Gesture {
        TapGesture().onEnded {
            self.focus = .transition(stateIndex: self.viewModel(forState: stateName).index, transitionIndex: transitionIndex)
            self.selectedObjects = [.transition(stateIndex: self.viewModel(forState: stateName).index, transitionIndex: transitionIndex)]
            self.delegate?.didChangeFocus(self)
        }
    }
    
    func setEdittingStateGesture(state stateName: StateName) -> some Gesture {
        TapGesture(count: 2).onEnded {
            self.edittingState = stateName
            self.focus = .state(stateIndex: self.viewModel(forState: stateName).index)
            self.delegate?.didChangeFocus(self)
        }
    }
    
}
