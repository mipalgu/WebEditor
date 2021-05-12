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

final class CanvasViewModel: ObservableObject {
    
    let machineRef: Ref<Machine>
    
    weak var notifier: GlobalChangeNotifier?
    
    private var stateViewModels: [StateName: StateViewModel]
    
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
        self.stateViewModels = Dictionary(uniqueKeysWithValues: layout?.states.compactMap { (stateName, stateLayout) in
            guard let index = machineRef.value.states.firstIndex(where: { $0.name == stateName }) else {
                return nil
            }
            return (stateName, StateViewModel(machine: machineRef, index: index, isText: false, layout: stateLayout, notifier: notifier))
        } ?? [])
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
    
}

extension CanvasViewModel: StateViewModelDelegate {
    
    func didChangeName(_ viewModel: StateViewModel, from oldName: String, to newName: String) {
        guard stateViewModels[oldName] != nil else {
            return
        }
        stateViewModels[newName] = viewModel
        objectWillChange.send()
    }
    
}

// MARK: - Gestures

extension CGRect {
    
    init(corner0: CGPoint, corner1: CGPoint) {
        let left: CGFloat
        let right: CGFloat
        let top: CGFloat
        let bottom: CGFloat
        if corner1.x > corner0.x {
            left = corner0.x
            right = corner1.x
        } else {
            left = corner1.x
            right = corner0.x
        }
        if corner1.y > corner0.y {
            top = corner0.y
            bottom = corner1.y
        } else {
            top = corner1.y
            bottom = corner0.y
        }
        let width = right - left
        let height = bottom - top
        self.init(origin: CGPoint(x: left, y: top), size: CGSize(width: width, height: height))
    }
    
}

extension CanvasViewModel {
    
    var selectionBoxGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpace))
            .modifiers(.shift)
            .onChanged {
                self.selectedBox = CGRect(corner0: $0.startLocation, corner1: $0.location)
            }
            .modifiers(.shift)
            .onEnded {
                self.selectedObjects = self.findObjectsInSelection(rect: CGRect(corner0: $0.startLocation, corner1: $0.location))
                self.selectedBox = nil
            }
    }
    
    /// Finds all the views within the selection box.
    /// - Parameters:
    ///   - corner0: A corner of the selection box.
    ///   - corner1: The second corner of the selection box (opposite to corner0).
    /// - Returns: A set of ViewTypes signifying the views within the selection box.
    private func findObjectsInSelection(rect: CGRect) -> Set<ViewType> {
        findSelectedStates(rect: rect).union(findSelectedTransitions(rect: rect))
    }
    
    /// Finds the states within the selection box.
    /// - Parameters:
    ///   - corner0: A corner of the selection box.
    ///   - corner1: The second corner of the selection box (opposite to corner0).
    /// - Returns: A set of ViewTypes signifying the states within the selection box.
    private func findSelectedStates(rect: CGRect) -> Set<ViewType> {
        if rect.width == 0 || rect.height == 0 {
            return []
        }
        return Set(machineRef.value.states.compactMap {
            let viewModel = viewModel(forState: $0.name)
            let position = viewModel.tracker.location
            if rect.contains(position) {
                return ViewType.state(stateIndex: viewModel.index)
            } else {
                return nil
            }
        })
    }
    
    
    /// Finds the transitions within the selection box.
    /// - Parameters:
    ///   - corner0: A corner of the selection box.
    ///   - corner1: The second corner of the selection box (opposite to corner0).
    /// - Returns: A set of ViewTypes signifying the transitions within the selection box.
    private func findSelectedTransitions(rect: CGRect) -> Set<ViewType> {
        if rect.width == 0, rect.height == 0 {
            return []
        }
        return Set(machineRef.value.states.flatMap { state in
            state.transitions.indices.compactMap { transitionIndex in
                let viewModel = viewModel(forTransition: transitionIndex, attachedToState: state.name)
                let position = viewModel.tracker.location
                if rect.contains(position) {
                    return ViewType.transition(stateIndex: viewModel.stateIndex, transitionIndex: transitionIndex)
                } else {
                    return nil
                }
            }
        })
    }
    
}
