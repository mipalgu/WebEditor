/*
 * ActionsViewModel.swift
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
import Attributes
import MetaMachines
import Utilities
import GUUI

final class ActionsViewModel: ObservableObject, Identifiable, ActionDelegate {
    
    let machineRef: Ref<MetaMachine>
    
    @Published var stateIndex: Int {
        willSet {
            actionViewModels.forEach {
                $1.stateIndex = newValue
            }
        }
    }
    
    private var actionViewModels: [String: ActionViewModel]
    
    var machine: MetaMachine {
        get {
            machineRef.value
        } set {
            machineRef.value = newValue
            objectWillChange.send()
        }
    }
    
    var path: Attributes.Path<MetaMachine, [Action]> {
        MetaMachine.path.states[stateIndex].actions
    }
    
    var actions: [String] {
        path.isNil(machineRef.value) ? [] : machineRef.value[keyPath: path.keyPath].map(\.name)
    }
    
    init(machine: Ref<MetaMachine>, stateIndex: Int) {
        self.machineRef = machine
        self.stateIndex = stateIndex
        self.actionViewModels = stateIndex >= machine.value.states.count ? [:] : Dictionary(uniqueKeysWithValues: machine.value.states[stateIndex].actions.enumerated().map {
            ($1.name, ActionViewModel(machine: machine, stateIndex: stateIndex, actionIndex: $0))
        })
        self.actionViewModels.values.forEach {
            $0.delegate = self
        }
    }
    
    func viewModel(forAction action: String) -> ActionViewModel {
        if let viewModel = actionViewModels[action] {
            return viewModel
        }
        guard let actionIndex = machineRef.value.states[stateIndex].actions.firstIndex(where: { $0.name == action }) else {
            fatalError("Unable to fetch action \(action).")
        }
        let viewModel = ActionViewModel(machine: machineRef, stateIndex: stateIndex, actionIndex: actionIndex)
        viewModel.delegate = self
        actionViewModels[action] = viewModel
        return viewModel
    }
    
    func expandedDidChange(old: Bool, new: Bool) {
        self.objectWillChange.send()
    }
    
}

extension ActionsViewModel {
    
    var expanded: [String: Bool] {
        Dictionary(uniqueKeysWithValues: actions.map {
            ($0, self.viewModel(forAction: $0).expanded)
        })
    }
    
    func getActionHeight(frame: CGSize, action: String) -> CGFloat {
        let minHeight: CGFloat = 100.0
        let expanded = expanded
        let expandedActions = expanded.values.filter { $0 }.count
        let collapsedActions = expanded.values.filter { !$0 }.count
        let collapsedHeight: CGFloat = 15.0
        guard let isExpanded = expanded[action], isExpanded else {
            return collapsedHeight
        }
        let padding = 10.0 + collapsedHeight * CGFloat(collapsedActions) + 5.0 * CGFloat(expandedActions)
        return max((frame.height - padding) / CGFloat(max(expandedActions, 1)), minHeight)
    }
    
}
