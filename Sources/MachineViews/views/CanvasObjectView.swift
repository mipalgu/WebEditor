/*
 * CanvasObjectView.swift
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

typealias CanvasObjectViewModel = ObservableObject & Positionable & Stretchable & TextRepresentable

extension Positionable {
    func clampedLocation(bounds: CGSize, offset: CGSize) -> CGPoint {
        CGPoint(
            x: min(max(offset.width, location.x), bounds.width - offset.width),
            y: min(max(offset.height, location.y), bounds.height - offset.height)
        )
    }
}

struct CanvasObjectView<ViewModel: CanvasObjectViewModel, Object: View>: View {
    
    @ObservedObject var viewModel: ViewModel
    
    let coordinateSpace: String
    
    let textRepresentation: String
    
    let textFrame: CGSize
    
    let frame: CGSize
    
    let object: () -> Object
    
//    let dragGesture: _EndedGesture<_ChangedGesture<DragGesture>>
    
    init(viewModel: ViewModel, coordinateSpace: String, textRepresentation: String, textFrame: CGSize = CGSize(width: 50, height: 20), frame: CGSize, object: @escaping () -> Object) {
        self.viewModel = viewModel
        self.coordinateSpace = coordinateSpace
        self.textRepresentation = textRepresentation
        self.textFrame = textFrame
        self.frame = frame
        self.object = object
//        self.dragGesture = dragGesture
    }
    
//    init(viewModel: ViewModel, coordinateSpace: String, textRepresentation: String, textFrame: CGSize = CGSize(width: 50, height: 20), object: @escaping () -> Object) {
//        let dragGesture = DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpace)).onChanged {
//            viewModel.location = $0.location
//        }.onEnded {
//            viewModel.location = $0.location
//        }
//        self.init(viewModel: viewModel, coordinateSpace: coordinateSpace, textRepresentation: textRepresentation, textFrame: textFrame, dragGesture: dragGesture, object: object)
//    }
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        if viewModel.isText {
            VStack {
                Text(textRepresentation)
                    .font(config.fontBody)
                    .frame(width: textFrame.width, height: textFrame.height)
            }
            .position(viewModel.clampedLocation(bounds: frame, offset: CGSize(width: textFrame.width / 2.0, height: textFrame.height / 2.0)))
            .coordinateSpace(name: coordinateSpace)
        } else {
            Group {
                object()
                    .frame(width: viewModel.width, height: viewModel.height)
            }
            .position(viewModel.location)
            .coordinateSpace(name: coordinateSpace)
//            .gesture(dragGesture)
        }
    }
    
}

import MetaMachines
import Utilities
import GUUI

struct CanvasObjectView_Previews: PreviewProvider {
    
    struct Preview: View {
        
        @StateObject var viewModel = StateViewModel(machine: Ref(copying: MetaMachine.initialSwiftMachine), index: 0)
        
        @State var expanded: Bool = false
        
        let config = Config()
        
        var body: some View {
            CanvasObjectView(viewModel: viewModel.tracker, coordinateSpace: "MAIN_VIEW", textRepresentation: viewModel.name, frame: CGSize(width: 1000, height: 1000)) {
                StateView(viewModel: viewModel).environmentObject(config)
            }
        }
        
    }
    
    static var previews: some View {
        VStack {
            Preview()
        }
    }
}
