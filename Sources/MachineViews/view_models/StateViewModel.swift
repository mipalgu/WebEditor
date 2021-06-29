/*
 * StateViewModel.swift
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
import Transformations
import Attributes
import AttributeViews
import Machines
import Utilities
import swift_helpers
import GUUI

protocol StateViewModelDelegate: AnyObject {
    
    func didChangeExpanded(_ viewModel: StateViewModel, from old: Bool, to new: Bool)
    func didChangeName(_ viewModel: StateViewModel, from oldName: StateName, to newName: StateName)
    func didChangeTransitionTarget(_ viewModel: StateViewModel, from oldName: StateName, to newName: StateName, transition: TransitionViewModel)
    func didDeleteTransition(_ viewModel: StateViewModel, transition: TransitionViewModel, targeting targetStateName: StateName)
    
}

final class StateViewModel: ObservableObject, Identifiable {
    
    weak var delegate: StateViewModelDelegate?
    
    weak var notifier: GlobalChangeNotifier?
    
    let machineRef: Ref<Machine>
    
    @Published var index: Int {
        willSet {
            actionsViewModel.stateIndex = newValue
            transitionViewModels.forEach {
                $1.stateIndex = newValue
            }
        }
    }
    
    let actionsViewModel: ActionsViewModel
    
    private var transitionViewModels: [Int: TransitionViewModel]
    
    public let tracker: StateTracker
    
    var expanded: Bool {
        get {
            tracker.expanded
        } set {
            let old = tracker.expanded
            tracker.expanded = newValue
            delegate?.didChangeExpanded(self, from: old, to: newValue)
            objectWillChange.send()
        }
    }
    
    var machine: Machine {
        get {
            machineRef.value
        } set {
            machineRef.value = newValue
            objectWillChange.send()
        }
    }
    
    var path: Attributes.Path<Machine, Machines.State> {
        Machine.path.states[index]
    }
    
    lazy var nameViewModel: LineViewModel = {
        LineViewModel(root: machineRef, path: path.name, label: "", notifier: notifier)
    }()
    
    var name: StateName {
        get {
            path.isNil(machineRef.value) ? "" : machineRef.value[keyPath: path.keyPath].name
        } set {
            guard !path.isNil(machineRef.value) else {
                return
            }
            let oldName = name
            if newValue == oldName {
                return
            }
            let result = machineRef.value.modify(attribute: path.name, value: newValue)
            defer { objectWillChange.send() }
            switch result {
            case .success(let notify):
                delegate?.didChangeName(self, from: oldName, to: newValue)
                if notify {
                    notifier?.send()
                }
            case .failure:
                notifier?.send()
            }
        }
    }
    
    var transitions: Range<Int> {
        path.isNil(machineRef.value) ? 0..<0 : machineRef.value[keyPath: path.keyPath].transitions.indices
    }
    
    var actions: [String] {
        actionsViewModel.actions
    }
    
    init(machine: Ref<Machine>, index: Int, isText: Bool = false, layout: StateLayout? = nil, notifier: GlobalChangeNotifier? = nil) {
        self.machineRef = machine
        self.index = index
        self.tracker = StateTracker(layout: layout, isText: isText, notifier: notifier)
        self.actionsViewModel = ActionsViewModel(machine: machine, stateIndex: index)
        if machine.value.states[index].transitions.isEmpty {
            self.transitionViewModels = [:]
        } else {
            self.transitionViewModels = Dictionary(uniqueKeysWithValues: layout?.transitions[0..<machine.value.states[index].transitions.count].enumerated().map {
                ($0, TransitionViewModel(machine: machine, stateIndex: index, transitionIndex: $0, layout: $1, notifier: notifier))
            } ?? [])
        }
        self.notifier = notifier
    }
    
    func removeTransitionViewModels(targeting stateName: StateName) {
        if path.isNil(machineRef.value) {
            return
        }
        let offsets = IndexSet(transitions.filter { self.viewModel(forTransition: $0).target == stateName })
        removeTransitionViewModels(atOffsets: offsets, countBeforeDeletion: transitions.upperBound)
    }
    
    func removeTransitionViewModels(atOffsets offsets: IndexSet, countBeforeDeletion count: Int) {
        offsets.forEach {
            transitionViewModels.removeValue(forKey: $0)
        }
        syncTransitions(afterDeleting: offsets, countBeforeDeletion: count)
    }
    
    func syncTransitions(afterDeleting indexSet: IndexSet, countBeforeDeletion count: Int) {
        if indexSet.isEmpty {
            return
        }
        var dict: [Int: TransitionViewModel] = [:]
        dict.reserveCapacity(count)
        var indexes = Array(0..<count)
        indexes.remove(atOffsets: indexSet) { (index, nextIndex, previouslyDeleted) in
            ((index + 1)..<nextIndex).forEach {
                let viewModel = viewModel(forTransition: $0)
                viewModel.transitionIndex -= previouslyDeleted
                dict[viewModel.transitionIndex] = viewModel
            }
        }
        transitionViewModels = dict
    }
    
    func deleteTransitions(in indexSet: IndexSet) {
        guard !indexSet.isEmpty, !path.isNil(machineRef.value) else {
            return
        }
        let sortedIndexSet = indexSet.sorted(by: >)
        let viewModels = Dictionary(uniqueKeysWithValues: sortedIndexSet.map { ($0, self.viewModel(forTransition: $0)) })
        let targetStateNames = viewModels.mapValues(\.target)
        let transitions = machineRef.value[keyPath: path.keyPath].transitions
        let result = machineRef.value.delete(transitions: indexSet, attachedTo: name)
        switch result {
        case .failure:
            notifier?.send()
            return
        case .success(let notify):
            defer {
                if notify {
                    notifier?.send()
                }
            }
            sortedIndexSet.forEach {
                guard let transitionViewModel = viewModels[$0], let targetStateName = targetStateNames[$0] else {
                    return
                }
                transitionViewModels[index] = nil
                delegate?.didDeleteTransition(self, transition: transitionViewModel, targeting: targetStateName)
            }
            syncTransitions(afterDeleting: indexSet, countBeforeDeletion: transitions.count)
        }
    }
    
    func deleteTransition(_ transitionIndex: Int) {
        guard !path.isNil(machineRef.value), machineRef.value[keyPath: path.keyPath].transitions.count > transitionIndex, transitionViewModels[transitionIndex] != nil else {
            return
        }
        let transitionViewModel = viewModel(forTransition: transitionIndex)
        let targetStateName = transitionViewModel.target
        let transitions = machineRef.value[keyPath: path.keyPath].transitions
        let result = machineRef.value.deleteTransition(atIndex: transitionIndex, attachedTo: name)
        switch result {
        case .failure:
            notifier?.send()
            return
        case .success(let notify):
            transitionViewModels[transitionIndex] = nil
            delegate?.didDeleteTransition(self, transition: transitionViewModel, targeting: targetStateName)
            defer {
                if notify {
                    notifier?.send()
                }
            }
            guard !path.isNil(machineRef.value) && !machineRef.value[keyPath: path.keyPath].transitions.isEmpty else {
                transitionViewModels.removeAll(keepingCapacity: true)
                return
            }
            guard transitionIndex + 1 < transitions.count else {
                return
            }
            // Remove transition view models for transitions that no longer exist
            // and update indexes of transition view models that have changed.
            let count = machineRef.value[keyPath: path.keyPath].transitions.count
            var dict: [Int: TransitionViewModel] = [:]
            dict.reserveCapacity(count)
            transitionViewModels.values.forEach { viewModel in
                if viewModel.transitionIndex - 1 >= count {
                    return
                }
                if viewModel.transitionIndex > transitionIndex {
                    viewModel.transitionIndex -= 1
                }
                dict[viewModel.transitionIndex] = viewModel
            }
            transitionViewModels = dict
            return
        }
        
    }
    
    func toggleExpand(frameWidth: CGFloat, frameHeight: CGFloat) {
        tracker.toggleExpand(frameWidth: frameWidth, frameHeight: frameHeight)
        objectWillChange.send()
    }
    
    func viewModels(targeting stateName: StateName) -> [TransitionViewModel] {
        transitionViewModels.values.filter { $0.target == stateName }
    }
    
    func viewModel(forAction action: String) -> ActionViewModel {
        self.actionsViewModel.viewModel(forAction: action)
    }
    
    func viewModel(forTransition transitionIndex: Int) -> TransitionViewModel {
        if let viewModel = transitionViewModels[transitionIndex] {
            return viewModel
        }
        let viewModel = TransitionViewModel(machine: machineRef, stateIndex: index, transitionIndex: transitionIndex)
        transitionViewModels[transitionIndex] = viewModel
        return viewModel
    }
    
    func send() {
        transitionViewModels.values.forEach {
            $0.send()
        }
        objectWillChange.send()
    }
    
}
