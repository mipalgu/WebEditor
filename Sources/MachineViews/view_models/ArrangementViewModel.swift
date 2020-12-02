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
import Utilities

import Foundation

public final class ArrangementViewModel: ObservableObject {
    
    @Reference public var arrangement: Arrangement
    
    @Published public var allMachines: [EditorViewModel]
    
    @Published public var currentMachineIndex: Int = 0
    
    public var rootMachineViewModels: [EditorViewModel] {
        let rootMachineNames = Set(arrangement.rootMachines.map { $0.name })
        return self.allMachines.filter { rootMachineNames.contains($0.machine.name) }
    }
    
    public var isEmpty: Bool {
        return arrangement.rootMachines.isEmpty
    }
    
    public var currentMachine: EditorViewModel {
        rootMachineViewModels[currentMachineIndex]
    }
    
    public var machineViewModels: [MachineViewModel] {
        self.allMachines.map { $0.machine }
    }
    
    public var rootMachinesAsDependencies: [MachineDependency] {
        rootMachineViewModels.map{
            let machine = $0.machine.machine
            return MachineDependency(name: machine.name, filePath: machine.filePath)
        }
    }
    
    public init(arrangement: Ref<Machines.Arrangement>) {
        self._arrangement = Reference(reference: arrangement)
        do {
            self.allMachines = try arrangement.value.allMachines().map {
                let manager = FileManager()
                let filePath: URL = $0.0
                let machineRef: Ref<Machine> = Ref(copying: $0.1)
                guard let plist = manager.contents(atPath: filePath.appendingPathComponent("Layout.plist").absoluteString),
                      let plistString = String(data: plist, encoding: .utf8) else {
                    return EditorViewModel(machine: MachineViewModel(machine: machineRef))
                }
                return EditorViewModel(machine: MachineViewModel(machine: machineRef, plist: plistString))
            }
        } catch let error {
            fatalError("No machines. Error: \(error)")
        }
        self.listen(to: $arrangement)
    }
    
    public func machine(id: UUID) -> MachineViewModel? {
        allMachines.first { $0.machine.id == id }?.machine
    }
    
    public func machine(name: String) -> MachineViewModel? {
        allMachines.first { $0.machine.name == name }?.machine
    }

    public func machineIndex(id: UUID) -> Int? {
        allMachines.firstIndex(where: { $0.machine.id == id })
    }
    
    public func machineIndex(name: String) -> Int? {
        allMachines.firstIndex(where: { $0.machine.name == name })
    }
    
    func state(machine: UUID, stateIndex: Int) -> StateViewModel? {
        guard let machine = self.machine(id: machine) else {
            print("Machine is nil")
            return nil
        }
        let states = machine.states
        return states[stateIndex]
    }
    
    public func addMachine(semantics: Machine.Semantics) -> EditorViewModel {
        let newMachine = Machine.initialMachine(forSemantics: semantics)
        let viewModel = EditorViewModel(machine: MachineViewModel(machine: Ref(copying: newMachine)))
        self.listen(to: viewModel)
        allMachines.append(viewModel)
        return viewModel
    }
    
    public func addRootMachine(semantics: Machine.Semantics) {
        let viewModel = addMachine(semantics: semantics)
        let dependency = MachineDependency(name: viewModel.machine.name, filePath: viewModel.machine.machine.filePath)
        arrangement.rootMachines.append(dependency)
    }
    
}
