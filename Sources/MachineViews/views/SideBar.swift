/*
 * SideBar.swift
 * 
 *
 * Created by Callum McColl on 14/5/21.
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

#if canImport(Cocoa)
import Cocoa
#endif

final class WidthTracker {
    
    var initialWidth: CGFloat? = nil
    
    init() {}
    
}

struct SideBar<Content: View>: View {
    
    enum Edge {
        case leading
        case trailing
    }
    
    @Binding var collapsed: Bool
    
    @Binding var width: CGFloat
    
    let edge: Edge
    
    let maxWidth: CGFloat
    
    let content: () -> Content
    
    let tracker = WidthTracker()
    
    var binding: Binding<CGFloat> {
        Binding(
            get: {
                if maxWidth.isInfinite {
                    return max(0, width)
                }
                return max(0, min(width, maxWidth))
            },
            set: {
                if maxWidth.isInfinite {
                    width = max(0, $0)
                } else {
                    width = max(0, min($0, maxWidth))
                }
            }
        )
    }
    
    init(collapsed: Binding<Bool>, width: Binding<CGFloat>, edge: Edge = .trailing, maxWidth: CGFloat = .infinity, content: @escaping () -> Content) {
        self._collapsed = collapsed
        self._width = width
        self.edge = edge
        self.maxWidth = maxWidth
        self.content = content
    }
    
    var body: some View {
        VStack {
            if !collapsed {
                VStack {
                    HStack {
                        content().animation(.none).frame(width: binding.wrappedValue)
                    }.overlay(
                        HStack {
                            if edge == .trailing {
                                Spacer()
                            }
                            Divider()
                            .onHover { hovering in
                                #if canImport(Cocoa)
                                if hovering {
                                    NSCursor.push(.resizeLeftRight)()
                                } else {
                                    NSCursor.pop()
                                }
                                #endif
                            }
                            .gesture(DragGesture().onChanged {
                                guard let initialWidth = tracker.initialWidth else {
                                    tracker.initialWidth = binding.wrappedValue
                                    binding.wrappedValue = edge == .trailing ? binding.wrappedValue + $0.translation.width : binding.wrappedValue - $0.translation.width
                                    return
                                }
                                binding.wrappedValue = edge == .trailing ? initialWidth + $0.translation.width : initialWidth - $0.translation.width
                            }.onEnded { _ in
                                tracker.initialWidth = nil
                            })
                            if edge == .leading {
                                Spacer()
                            }
                        }
                    )
                }.frame(width: binding.wrappedValue)
            }
        }.transition(.move(edge: edge == .trailing ? .trailing : .leading)).animation(.interactiveSpring())
    }
    
}
