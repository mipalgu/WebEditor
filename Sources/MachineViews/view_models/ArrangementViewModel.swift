/*
 * AppViewModel.swift
 * MachineViews
 *
 * Created by Callum McColl on 27/11/20.
 * Copyright © 2020 Callum McColl. All rights reserved.
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

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

public final class ArrangementViewModel: ObservableObject {
    
    @Published public var rootMachineViewModels: [EditorViewModel]
    
    @Published public var focusedView: EditorViewModel
    
    @Published var leftPaneCollapsed: Bool = false
    
    @Published var leftDivider: BoundedPositionViewModel
    
    let leftPaneMaxWidth: CGFloat = 500
    
    let leftPaneMinWidth: CGFloat = 300
    
    let collapsedPaneWidth: CGFloat = 50.0
    
    var dividerWidth: CGFloat {
        leftDivider.width
    }
    
    var leftPaneWidth: CGFloat {
        if leftPaneCollapsed {
            return collapsedPaneWidth
        }
        return max(min(leftPaneMaxWidth, leftDivider.location.x - dividerWidth / 2.0), leftPaneMinWidth)
    }

    public convenience init(rootMachines: [Machine], editorWidth: CGFloat, editorHeight: CGFloat) {
        let x = editorWidth - 500
        self.init(
            rootMachineViewModels: rootMachines.indices.map {
                EditorViewModel(
                    machine: MachineViewModel(machine: Ref(copying: rootMachines[$0])),
                    dividerViewModel: BoundedPositionViewModel(
                        location: CGPoint(x: x, y: editorHeight / 2.0),
                        width: 10.0,
                        height: editorHeight,
                        minX: x,
                        maxX: editorWidth,
                        minY: 0,
                        maxY: editorHeight
                    )
                )
            },
            leftDivider: BoundedPositionViewModel(
                location: CGPoint(x: 500, y: editorHeight / 2.0),
                width: 10.0,
                height: editorHeight,
                minX: 300,
                maxX: 500,
                minY: 0,
                maxY: editorHeight
            )
        )
    }
    
    public init(rootMachineViewModels: [EditorViewModel], leftDivider: BoundedPositionViewModel) {
        if rootMachineViewModels.count == 0 {
            fatalError("Cannot load editor with no machines.")
        }
        self.rootMachineViewModels = rootMachineViewModels
        self.focusedView = rootMachineViewModels.first!
        self.leftDivider = leftDivider
        
    }
    
    public func machine(id: UUID) -> MachineViewModel? {
        return rootMachineViewModels.first { $0.machine.id == id }?.machine
    }

    public func machineIndex(id: UUID) -> Int? {
        rootMachineViewModels.firstIndex(where: { $0.machine.id == id })
    }
    
    func state(machine: UUID, stateIndex: Int) -> StateViewModel? {
        guard let machine = self.machine(id: machine) else {
            print("Machine is nil")
            return nil
        }
        let states = machine.states
        return states[stateIndex]
    }
    
    func rightPaneStartLocation(width: CGFloat, height: CGFloat) -> CGPoint {
        let offset = leftDivider.location.x + dividerWidth / 2.0
        let x = leftPaneWidth + 2.0 * dividerWidth + focusedView.getDividerLocation(width: width - offset , height: height).x
        return CGPoint(x: x, y: height / 2.0)
    }
}
