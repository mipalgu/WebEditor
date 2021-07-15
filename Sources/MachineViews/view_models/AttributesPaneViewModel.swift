/*
 * AttributesPaneViewModel.swift
 * 
 *
 * Created by Callum McColl on 13/5/21.
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
import AttributeViews
import Attributes
import MetaMachines
import Utilities
import GUUI

final class AttributesPaneViewModel: ObservableObject, GlobalChangeNotifier {
    
    weak var notifier: GlobalChangeNotifier?
    
    let machineRef: Ref<MetaMachine>
    
    private let focusRef: Ref<Focus>
    
    @Published var attributesCollapsed: Bool = false
    @Published var attributesWidth: CGFloat = 400
    
    private var focusViewModels: [Focus: AttributeGroupsViewModel<MetaMachine>] = [:]
    
    var attributeGroupsViewModel: AttributeGroupsViewModel<MetaMachine> {
        if let viewModel = focusViewModels[focus] {
            return viewModel
        }
        switch focus {
        case .machine:
            let viewModel = AttributeGroupsViewModel(rootRef: machineRef, path: MetaMachine.path.attributes, notifier: notifier)
            focusViewModels[focus] = viewModel
            return viewModel
        case .state(let stateIndex):
            var path = MetaMachine.path.states[stateIndex].attributes
            if path.isNil(machineRef.value) || machineRef.value[keyPath: path.keyPath].isEmpty {
                path = MetaMachine.path.attributes
            }
            let viewModel = AttributeGroupsViewModel(rootRef: machineRef, path: path, notifier: notifier)
            focusViewModels[focus] = viewModel
            return viewModel
        case .transition(let stateIndex, let transitionIndex):
            var path = MetaMachine.path.states[stateIndex].transitions[transitionIndex].attributes
            if path.isNil(machineRef.value) || machineRef.value[keyPath: path.keyPath].isEmpty {
                path = MetaMachine.path.states[stateIndex].attributes
            }
            if path.isNil(machineRef.value) || machineRef.value[keyPath: path.keyPath].isEmpty {
                path = MetaMachine.path.attributes
            }
            let viewModel = AttributeGroupsViewModel(rootRef: machineRef, path: path, notifier: notifier)
            focusViewModels[focus] = viewModel
            return viewModel
        }
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
        focusRef.value
    }
    
    var label: String {
        switch focus {
        case .machine:
            return "Machine: \(machine.name)"
        case .state(let stateIndex):
            if MetaMachine.path.states[stateIndex].isNil(machineRef.value) {
                return ""
            }
            return "State: \(machine.states[stateIndex].name)"
        case .transition(let stateIndex, let transitionIndex):
            if MetaMachine.path.states[stateIndex].isNil(machineRef.value) {
                return ""
            }
            return "State \(machine.states[stateIndex].name) Transition \(transitionIndex)"
        }
    }
    
    var extraTabs: (() -> AnyView)? {
        let machineExtraTabs = {
            AnyView(DependenciesAttributesView(
                root: Binding(get: { self.machine }, set: { self.machine = $0 }),
                path: MetaMachine.path,
                label: "Dependencies"
            ))
        }
        let stateExtraTabs: (() -> AnyView)? = nil
        let transitionExtraTabs: (() -> AnyView)? = nil
        switch focus {
        case .machine:
            return machineExtraTabs
        case .state(let stateIndex):
            let path = MetaMachine.path.states[stateIndex].attributes
            if path.isNil(machineRef.value) || machineRef.value[keyPath: path.keyPath].isEmpty {
                return machineExtraTabs
            } else {
                return stateExtraTabs
            }
        case .transition(let stateIndex, let transitionIndex):
            var path = MetaMachine.path.states[stateIndex].transitions[transitionIndex].attributes
            if path.isNil(machineRef.value) || machineRef.value[keyPath: path.keyPath].isEmpty {
                path = MetaMachine.path.states[stateIndex].attributes
            } else {
                return transitionExtraTabs
            }
            if path.isNil(machineRef.value) || machineRef.value[keyPath: path.keyPath].isEmpty {
                return machineExtraTabs
            } else {
                return stateExtraTabs
            }
        }
    }
    
    init(machineRef: Ref<MetaMachine>, focusRef: Ref<Focus>, notifier: GlobalChangeNotifier? = nil) {
        self.machineRef = machineRef
        self.focusRef = focusRef
        self.notifier = notifier
    }
    
    func send() {
        attributeGroupsViewModel.send()
        objectWillChange.send()
    }
    
}
