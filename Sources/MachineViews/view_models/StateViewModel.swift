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

final class StateViewModel: ObservableObject, Identifiable {
    
    let machineRef: Ref<Machine>
    
    weak var notifier: GlobalChangeNotifier?
    
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
            tracker.expanded = newValue
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
    
    var name: StateName {
        path.isNil(machineRef.value) ? "" : machineRef.value[keyPath: path.keyPath].name
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
                ($0, TransitionViewModel(machine: machine, stateIndex: index, transitionIndex: $0, layout: $1))
            } ?? [])
        }
        self.notifier = notifier
    }
    
    func deleteTransition(_ transitionIndex: Int) {
        guard !path.isNil(machineRef.value), machineRef.value[keyPath: path.keyPath].transitions.count > transitionIndex, transitionViewModels[transitionIndex] != nil else {
            return
        }
        let transitions = machineRef.value[keyPath: path.keyPath].transitions
        let result = machineRef.value.deleteTransition(atIndex: transitionIndex, attachedTo: name)
        switch result {
        case .failure:
            notifier?.send()
            return
        case .success(let notify):
            transitionViewModels[transitionIndex] = nil
            if transitionIndex + 1 < transitions.count {
                ((transitionIndex + 1)..<transitions.count).forEach {
                    let viewModel = viewModel(forTransition: $0)
                    viewModel.transitionIndex -= 1
                }
            }
            if notify {
                notifier?.send()
            }
            return
        }
        
    }
    
    func toggleExpand(frameWidth: CGFloat, frameHeight: CGFloat) {
        tracker.toggleExpand(frameWidth: frameWidth, frameHeight: frameHeight)
        objectWillChange.send()
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
    
}
