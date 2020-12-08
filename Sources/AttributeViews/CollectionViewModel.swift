/*
 * CollectionViewModel.swift
 * MachineViews
 *
 * Created by Callum McColl on 23/11/20.
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

final class CollectionViewModel: AttributeViewModel<[Attribute]> {
    
    let _addElement: (CollectionViewModel) -> Void
    let _deleteElement: (CollectionViewModel, ListElement<Attribute>, Int) -> Void
    let _deleteElements: (CollectionViewModel, IndexSet) -> Void
    let _moveElements: (CollectionViewModel, IndexSet, Int) -> Void
    
    @Published public var newAttribute: Attribute
    
    @Published public var selection: Set<UUID> = []
    
    @Published private var currentElements: [ListElement<Attribute>]
    
    public var elements: [ListElement<Attribute>] {
        get {
            let rootElements = super.value
            let elements = zip(rootElements, currentElements).map { (rootElement, currentElement) -> ListElement<Attribute> in
                if rootElement == currentElement.value {
                    return currentElement
                }
                return ListElement(rootElement)
            }
            if rootElements.count <= elements.count {
                return elements
            }
            return elements + rootElements[elements.count..<rootElements.count].map { ListElement($0) }
        } set {
            zip(currentElements, newValue).enumerated().forEach {
                if $1.0.value == $1.1.value {
                    return
                }
                currentElements[$0] = $1.1
            }
            if newValue.count > currentElements.count {
                currentElements.append(contentsOf: newValue[currentElements.count..<newValue.count])
            }
        }
    }
    
    init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, [Attribute]>, type: AttributeType) {
        self._addElement = { me in
            do {
                try root.value.addItem(me.newAttribute, to: path)
                me.newAttribute = type.defaultValue
            } catch let e {
                me.error = "\(e)"
            }
            me.currentElements = root.value[keyPath: path.keyPath].map { ListElement($0) }
        }
        self._deleteElement = { (me, element, index) in
            let offsets: IndexSet = me.selection.contains(element.id)
                ? IndexSet(me.elements.enumerated().lazy.filter { me.selection.contains($1.id) }.map { $0.0 })
                : [index]
            me.deleteElements(offsets: offsets)
        }
        self._deleteElements = { (me, offsets) in
            do {
                try root.value.deleteItems(table: path, items: offsets)
                return
            } catch let e {
                me.error = "\(e)"
            }
            me.currentElements = root.value[keyPath: path.keyPath].map { ListElement($0) }
        }
        self._moveElements = { (me, source, destination) in
            do {
                try root.value.moveItems(table: path, from: source, to: destination)
            } catch let e {
                me.error = "\(e)"
            }
            me.currentElements = root.value[keyPath: path.keyPath].map { ListElement($0) }
        }
        self.newAttribute = type.defaultValue
        self.currentElements = root.value[keyPath: path.keyPath].map { ListElement($0) }
        super.init(root: root, path: path)
    }
    
    init(binding value: Binding<[Attribute]>, type: AttributeType) {
        self._addElement = { me in
            value.wrappedValue.append(me.newAttribute)
            me.newAttribute = type.defaultValue
            me.currentElements = value.wrappedValue.map { ListElement($0) }
        }
        self._deleteElement = { (me, element, index) in
            let offsets: IndexSet = me.selection.contains(element.id)
                ? IndexSet(me.elements.enumerated().lazy.filter { me.selection.contains($1.id) }.map { $0.0 })
                : [index]
            me.deleteElements(offsets: offsets)
        }
        self._deleteElements = { (me, offsets) in
            value.wrappedValue.remove(atOffsets: offsets)
            me.currentElements = value.wrappedValue.map { ListElement($0) }
        }
        self._moveElements = { (me, source, destination) in
            value.wrappedValue.move(fromOffsets: source, toOffset: destination)
            me.currentElements = value.wrappedValue.map { ListElement($0) }
        }
        self.newAttribute = type.defaultValue
        self.currentElements = value.wrappedValue.map { ListElement($0) }
        super.init(binding: value)
    }
    
    public func addElement() {
        self._addElement(self)
    }
    
    public func deleteElement(_ element: ListElement<Attribute>, atIndex index: Int) {
        self._deleteElement(self, element, index)
    }
    
    public func deleteElements(offsets: IndexSet) {
        self._deleteElements(self, offsets)
    }
    
    public func moveElements(source: IndexSet, destination: Int) {
        self._moveElements(self, source, destination)
    }
    
}
