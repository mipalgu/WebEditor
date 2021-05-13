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
import Machines
import Utilities

final class AttributesPaneViewModel: ObservableObject {
    
    let machineRef: Ref<Machine>
    
    private let focusRef: Ref<Focus>
    
    weak var notifier: GlobalChangeNotifier?
    
    @Published var attributesCollapsed: Bool = false
    
    private var machineSelection: Int?
    
    private var stateSelection: Int?
    
    private var transitionSelection: Int?

    private var stateIndex: Int = -1
    
    private var transitionIndex: Int = -1
    
    lazy var attributeGroupsViewModel: AttributeGroupsViewModel<Machine> = {
        AttributeGroupsViewModel(rootRef: machineRef, path: Machine.path.attributes, selectionRef: selectionRef, notifier: notifier)
    }()
    
    var machine: Machine {
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
    
    var selection: Int? {
        get {
            switch focus {
            case .machine:
                return machineSelection.map { $0 >= machine.attributes.count } == true ? nil : machineSelection
            case .state(let index):
                if index >= machine.states.count {
                    return nil
                }
                return stateSelection.map { $0 >= machine.states[index].attributes.count } == true ? nil : stateSelection
            case .transition(let stateIndex, let transitionIndex):
                if stateIndex >= machine.states.count || transitionIndex >= machine.states[stateIndex].transitions.count {
                    return nil
                }
                return transitionSelection.map { $0 >= machine.states[stateIndex].transitions[transitionIndex].attributes.count } == true ? nil : transitionSelection
            }
        } set {
            switch focus {
            case .machine:
                machineSelection = newValue
            case .state:
                stateSelection = newValue
            case .transition:
                transitionSelection = newValue
            }
        }
    }
    
    var selectionRef: Ref<Int?> {
        Ref(
            get: { self.selection },
            set: { self.selection = $0 }
        )
    }
    
    var path: Attributes.Path<Machine, [AttributeGroup]> {
        switch focus {
            case .machine:
                return machine.path.attributes
            case .state(let stateIndex):
                let path = machine.path.states[stateIndex].attributes
                if !path.isNil(machine) {
                    return path
                }
                return machine.path.attributes
            case .transition(let stateIndex, let transitionIndex):
                let path = machine.path.states[stateIndex].transitions[transitionIndex].attributes
                if !path.isNil(machine) && !machine.states[stateIndex].transitions[transitionIndex].attributes.isEmpty {
                    return path
                }
                let statePath = machine.path.states[stateIndex].attributes
                if !statePath.isNil(machine) && !machine.states[stateIndex].attributes.isEmpty {
                    return statePath
                }
                return machine.path.attributes
        }
    }
    
    var label: String {
        switch focus {
        case .machine:
            return "Machine: \(machine.name)"
        case .state(let stateIndex):
            return "State: \(machine.states[stateIndex].name)"
        case .transition(let stateIndex, let transitionIndex):
            return "State \(machine.states[stateIndex].name) Transition \(transitionIndex)"
        }
    }
    
    init(machineRef: Ref<Machine>, focusRef: Ref<Focus>, notifier: GlobalChangeNotifier? = nil) {
        self.machineRef = machineRef
        self.focusRef = focusRef
        self.notifier = notifier
    }
    
    func changingFocus(to newValue: Focus) {
        switch newValue {
        case .machine:
            break
        case .state(let index):
            if index != stateIndex {
                stateSelection = nil
            }
            stateIndex = index
        case .transition(let stateIndex, let transitionIndex):
            if stateIndex != self.stateIndex || transitionIndex != self.transitionIndex {
                self.transitionSelection = nil
            }
            self.transitionIndex = transitionIndex
        }
        attributeGroupsViewModel.objectWillChange.send()
        objectWillChange.send()
    }
    
}
