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
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, [Attribute]>?
    let label: String
    let type: AttributeType
    
    @State var newAttribute: Attribute
    
    @State var value: [Attribute]
    
    @State private var selection: Set<UUID> = []
    
    @State var ids: [UUID]
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, [Attribute]>?, label: String, type: AttributeType, defaultValue: [Attribute] = []) {
        self._machine = machine
        self.path = path
        self.label = label
        self.type = type
        self._value = State(initialValue: path.map { machine.wrappedValue[keyPath: $0.keyPath] } ?? defaultValue)
        self._newAttribute = State(initialValue: type.defaultValue)
        self._ids = State(initialValue: (path.map { machine.wrappedValue[keyPath: $0.keyPath] } ?? defaultValue).map { _ in UUID() })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label + ":").fontWeight(.bold)
            HStack {
                switch type {
                case .line:
                    AttributeView(machine: $machine, attribute: $newAttribute, path: nil, label: "New " + label)
                    Button(action: {
                        guard let path = self.path else {
                            return
                        }
                        do {
                            try machine.addItem(newAttribute, to: path)
                            newAttribute = type.defaultValue
                        } catch let e {
                            print("\(e)", stderr)
                        }
                        self.value = machine[keyPath: path.keyPath]
                    }, label: {
                        Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                    }).buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
                case .block:
                    EmptyView()
                }
//                Spacer()
//                Button(action: {
//                    guard let path = self.path else {
//                        return
//                    }
//                    do {
//                        try machine.deleteItems(table: path, items: IndexSet(selection))
//                        return
//                    } catch let e {
//                        print("\(e)", stderr)
//                    }
//                    value = machine[keyPath: path.keyPath]
//                }, label: {
//                    Image(systemName: "minus").font(.system(size: 16, weight: .regular))
//                }).buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
            }.padding(.bottom, 5)
            Divider()
            List(selection: $selection) {
                ForEach(Array(zip(ids, value.indices)), id: \.0) { (id, index) in
                    HStack(spacing: 1) {
                        AttributeView(machine: $machine, attribute: $value[index], path: path?[index], label: "")
                        Image(systemName: "ellipsis").font(.system(size: 16, weight: .regular)).rotationEffect(.degrees(90))
                    }
                    .contextMenu {
                        Button("Delete", action: {
                            let backup = ids
                            let offsets = IndexSet(selection.compactMap { ids.firstIndex(of: $0) })
                            ids.remove(atOffsets: offsets)
                            value.remove(atOffsets: offsets)
                            guard let path = self.path else {
                                return
                            }
                            do {
                                print(selection)
                                try machine.deleteItems(table: path, items: offsets)
                                return
                            } catch let e {
                                print("\(e)", stderr)
                            }
                            value = machine[keyPath: path.keyPath]
                            ids = backup
                        }).keyboardShortcut(.delete)
                    }
                }.onMove { (source, destination) in
                    value.move(fromOffsets: source, toOffset: destination)
                    guard let path = self.path else {
                        return
                    }
                    do {
                        try machine.moveItems(table: path, from: source, to: destination)
                        return
                    } catch let e {
                        print("\(e)", stderr)
                    }
                    value = machine[keyPath: path.keyPath]
                }
//                .onDelete {
//                    value.remove(atOffsets: $0)
//                    guard let path = self.path else {
//                        return
//                    }
//                    do {
//                        try machine.deleteItems(table: path, items: $0)
//                        return
//                    } catch let e {
//                        print("\(e)", stderr)
//                    }
//                    value = machine[keyPath: path.keyPath]
//                }
            }.frame(minHeight: CGFloat(value.count * (type == .line ? 30 : 80) + 10))
        }
    }
}
