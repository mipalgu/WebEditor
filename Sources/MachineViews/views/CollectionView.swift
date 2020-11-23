/*
 * CollectionView.swift
 * MachineViews
 *
 * Created by Callum McColl on 16/11/20.
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

struct CollectionView: View{
    
    @StateObject var viewModel: CollectionViewModel
    
    init(machine: Ref<Machine>, path: Attributes.Path<Machine, [Attribute]>?, label: String, type: AttributeType, defaultValue: [Attribute] = []) {
        self._viewModel = StateObject(wrappedValue: CollectionViewModel(machine: machine, path: path, label: label, type: type, defaultValue: defaultValue))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.label + ":").fontWeight(.bold)
//            HStack {
//                switch type {
//                case .line:
//                    AttributeView(machine: viewModel.machine.asBinding, attribute: $viewModel.newAttribute, path: nil, label: "New " + viewModel.label)
////                    Button(action: {
////                        guard let path = self.path else {
////                            value.append(ListElement(newAttribute))
////                            newAttribute = type.defaultValue
////                            return
////                        }
////                        do {
////                            try machine.addItem(newAttribute, to: path)
////                            newAttribute = type.defaultValue
////                        } catch let e {
////                            print("\(e)", stderr)
////                        }
////                        self.value = machine[keyPath: path.keyPath].map { ListElement($0) }
////                    }, label: {
////                        Image(systemName: "plus").font(.system(size: 16, weight: .regular))
////                    }).buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
//                case .block:
//                    EmptyView()
//                }
//            }.padding(.bottom, 5)
            Divider()
            List(selection: $viewModel.selection) {
                ForEach(Array(viewModel.elements.enumerated()), id: \.1.id) { (index, element) in
                    HStack(spacing: 1) {
                        AttributeView(
                            machine: viewModel.$machine,
                            attribute: $viewModel.elements[index].value,
                            path: viewModel.path?[index],
                            label: ""
                        )
                        Image(systemName: "ellipsis").font(.system(size: 16, weight: .regular)).rotationEffect(.degrees(90))
                    }
//                    .contextMenu {
//                        Button("Delete", action: {
//                            let offsets: IndexSet = selection.contains(element.id)
//                                ? IndexSet(elements.enumerated().lazy.filter { selection.contains($1.id) }.map { $0.0 })
//                                : [index]
//                            guard let path = self.path else {
//                                value.remove(atOffsets: offsets)
//                                return
//                            }
//                            do {
//                                try machine.deleteItems(table: path, items: offsets)
//                                return
//                            } catch let e {
//                                print("\(e)", stderr)
//                            }
//                            value = machine[keyPath: path.keyPath].map { ListElement($0) }
//                        }).keyboardShortcut(.delete)
//                    }
                }
//                .onMove { (source, destination) in
//                    guard let path = self.path else {
//                        value.move(fromOffsets: source, toOffset: destination)
//                        return
//                    }
//                    do {
//                        try machine.moveItems(table: path, from: source, to: destination)
//                    } catch let e {
//                        print("\(e)", stderr)
//                    }
//                    value = machine[keyPath: path.keyPath].map { ListElement($0) }
//                }
//                .onDelete { offsets in
//                    guard let path = self.path else {
//                        value.remove(atOffsets: offsets)
//                        return
//                    }
//                    do {
//                        try machine.deleteItems(table: path, items: offsets)
//                        return
//                    } catch let e {
//                        print("\(e)", stderr)
//                    }
//                    value = machine[keyPath: path.keyPath].map { ListElement($0) }
//                }
            }.frame(minHeight: CGFloat(viewModel.elements.count * (viewModel.type == .line ? 30 : 80) + 10))
        }
    }
}
