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

final class StateViewModel: ObservableObject, Identifiable, MoveAndStretchFromDrag, _Collapsable, Collapsable, EdgeDetector, TextRepresentable, BoundedSize, _Rigidable {
    
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
    
    var transitions: Range<Int> {
        path.isNil(machineRef.value) ? 0..<0 : machineRef.value[keyPath: path.keyPath].transitions.indices
    }
    
    var actions: [String] {
        actionsViewModel.actions
    }
    
    var stateNames: [String] {
        machineRef.value.states.map(\.name)
    }
    
    @Published var isText: Bool {
        didSet {
            guard let notifier = notifier else {
                return
            }
            notifier.send()
        }
    }
    
    var isDragging: Bool = false
    
    @Published var _collapsedWidth: CGFloat {
        didSet {
            guard let notifier = notifier else {
                return
            }
            notifier.send()
        }
    }
    
    @Published var _collapsedHeight: CGFloat {
        didSet {
            guard let notifier = notifier else {
                return
            }
            notifier.send()
        }
    }
    
    @Published var expanded: Bool {
        didSet {
            guard let notifier = notifier else {
                return
            }
            notifier.send()
        }
    }
    
    @Published var location: CGPoint

    let collapsedMinWidth: CGFloat = 150.0
    
    let collapsedMaxWidth: CGFloat = 250.0
    
    let collapsedMinHeight: CGFloat = 100.0
    
    let collapsedMaxHeight: CGFloat = 125.0
    
    @Published var _expandedWidth: CGFloat {
        didSet {
            guard let notifier = notifier else {
                return
            }
            notifier.send()
        }
    }
    
    @Published var _expandedHeight: CGFloat {
        didSet {
            guard let notifier = notifier else {
                return
            }
            notifier.send()
        }
    }
    
    var offset: CGPoint = CGPoint.zero
    
    let expandedMinWidth: CGFloat = 200.0
    
    let expandedMaxWidth: CGFloat = 600.0
    
    let expandedMinHeight: CGFloat = 150.0
    
    var expandedMaxHeight: CGFloat = 300.0
    
    var isStretchingX: Bool = false
    
    var isStretchingY: Bool = false
    
    let _collapsedTolerance: CGFloat = 0
    
    let _expandedTolerance: CGFloat = 20.0
    
    var horizontalEdgeTolerance: CGFloat {
        expanded ? _expandedTolerance : _collapsedTolerance
    }
    
    var verticalEdgeTolerance: CGFloat {
        horizontalEdgeTolerance
    }
    
    init(machine: Ref<Machine>, index: Int, isText: Bool = false, layout: StateLayout? = nil, notifier: GlobalChangeNotifier? = nil) {
        self.machineRef = machine
        self.index = index
        self.isText = isText
        self.expanded = layout?.expanded ?? false
        self.location = layout.map { CGPoint(x: $0.x, y: $0.y) } ?? .zero
        self._collapsedWidth = (layout?.expanded == true ? 150 : layout?.width) ?? 150
        self._collapsedHeight = (layout?.expanded == true ? 100 : layout?.height) ?? 100
        self._expandedWidth = (layout?.expanded == true ? layout?.width : 200) ?? 200
        self._expandedHeight = (layout?.expanded == true ? layout?.height : 150) ?? 150
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
    
    func toggleExpand(frameWidth: CGFloat, frameHeight: CGFloat) {
        self.expanded = !self.expanded
        let newLocation: CGPoint
        if self.expanded {
            newLocation = CGPoint(
                x: self.location.x,
                y: self.location.y + collapsedHeight / 2.0
            )
        } else {
            newLocation = CGPoint(
                x: self.location.x,
                y: self.location.y - expandedHeight / 2.0
            )
        }
        self.setLocation(width: frameWidth, height: frameHeight, newLocation: newLocation)
    }
    
}
