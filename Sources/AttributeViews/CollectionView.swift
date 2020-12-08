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

import Attributes
import Utilities

public struct CollectionView: View{
    
    @StateObject var viewModel: CollectionViewModel
    let subView: (Int) -> AttributeView
    let label: String
    let type: AttributeType
    
    @EnvironmentObject var config: Config
    
    @State var creating: Bool = false
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, [Attribute]>, label: String, type: AttributeType) {
        self.init(viewModel: CollectionViewModel(root: root, path: path, type: type), label: label, type: type) {
            AttributeView(root: root, path: path[$0], label: "")
        }
    }
    
    public init(value: Binding<[Attribute]>, label: String, type: AttributeType) {
        self.init(viewModel: CollectionViewModel(binding: value, type: type), label: label, type: type) {
            AttributeView(attribute: value[$0], label: "")
        }
    }
    
    init(viewModel: CollectionViewModel, label: String, type: AttributeType, subView: @escaping (Int) -> AttributeView) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.subView = subView
        self.label = label
        self.type = type
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            VStack {
                switch type {
                case .line:
                    HStack {
                        AttributeView(attribute: $viewModel.newAttribute, label: "New " + label)
                        Button(action: viewModel.addElement, label: {
                            Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                        }).buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
                    }
                case .block:
                    if creating {
                        HStack {
                            Text(label + ":").fontWeight(.bold)
                            Spacer()
                            Button(action: {
                                viewModel.addElement()
                                creating = false
                            }, label: {
                                Image(systemName: "square.and.pencil").font(.system(size: 16, weight: .regular))
                            }).buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
                            Divider()
                            Button(action: {
                                creating = false
                            }, label: {
                                Image(systemName: "trash").font(.system(size: 16, weight: .regular))
                            }).animation(.easeOut).buttonStyle(PlainButtonStyle()).foregroundColor(.red)
                        }
                        AttributeView(attribute: $viewModel.newAttribute, label: "")
                    } else {
                        HStack {
                            Text(label + ":").fontWeight(.bold)
                            Spacer()
                            Button(action: { creating = true }, label: {
                                Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                            }).animation(.easeOut).buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
                        }
                    }
                }
            }.padding(.bottom, 5)
            Divider()
            if !viewModel.elements.isEmpty {
                List(selection: $viewModel.selection) {
                    ForEach(Array(viewModel.elements.enumerated()), id: \.1.id) { (index, element) in
                        HStack(spacing: 1) {
                            subView(index)
                            Image(systemName: "ellipsis").font(.system(size: 16, weight: .regular)).rotationEffect(.degrees(90))
                        }.contextMenu {
                            Button("Delete", action: { viewModel.deleteElement(element, atIndex: index) }).keyboardShortcut(.delete)
                        }
                    }.onMove(perform: viewModel.moveElements).onDelete(perform: viewModel.deleteElements)
                }.frame(minHeight: min(CGFloat(viewModel.elements.count * (type == .line ? 30 : 80) + 10), 100))
            }
        }.padding(.top, 2)
    }
}
