/*
 * Ref.swift
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

@dynamicMemberLookup
public class ConstRef<T>: ObservableObject, Identifiable {
    
    public var id: Int {
        Int(bitPattern: Unmanaged.passUnretained(self).toOpaque())
    }
    
    fileprivate var get: () -> T
    
    public var value: T {
        self.get()
    }
    
    public convenience init(copying value: T) {
        self.init(get: { value })
    }
    
    fileprivate init(get: @escaping () -> T) {
        self.get = get
    }
    
    public subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> ConstRef<U> {
        return ConstRef<U> { self.get()[keyPath: keyPath] }
    }
    
    public subscript<Path: ReadOnlyPathProtocol>(readOnly path: Path) -> ConstRef<Path.Value> where Path.Root == T {
        return self[dynamicMember: path.keyPath]
    }
    
}

extension ConstRef where T: ObservableObject {
    
    public convenience init(observing value: T) {
        self.init(get: { value })
        self.listen(to: value)
    }
    
}

@dynamicMemberLookup
public final class Ref<T>: ConstRef<T> {
    
    fileprivate var set: (T) -> Void
    
    public override var value: T {
        get {
            get()
        } set {
            self.objectWillChange.send()
            set(newValue)
        }
    }
    
    public var asBinding: Binding<T> {
        return Binding(get: { self.value }, set: { self.value = $0 })
    }
    
    public convenience init(to pointer: UnsafeMutablePointer<T>) {
        self.init(get: { pointer.pointee }, set: { pointer.pointee = $0 })
    }
    
    public convenience init(copying value: T) {
        var value = value
        self.init(get: { value }, set: { value = $0 })
    }
    
    private init(get: @escaping () -> T, set: @escaping (T) -> Void) {
        self.set = set
        super.init(get: get)
    }
    
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<T, U>) -> Ref<U> {
        return Ref<U>(
            get: { self.get()[keyPath: keyPath] },
            set: {
                var value = self.value
                value[keyPath: keyPath] = $0
                self.value = value
            }
        )
    }
    
    public subscript<Path: PathProtocol>(path path: Path) -> Ref<Path.Value> where Path.Root == T {
        return self[dynamicMember: path.path]
    }
    
    public subscript<Path: PathProtocol>(bindingTo path: Path) -> Binding<Path.Value> where Path.Root == T {
        self[path: path].asBinding
    }
    
}

extension Ref where T: ObservableObject {
    
    public convenience init(observing value: T) {
        var value = value
        self.init(get: { value }, set: { value = $0 })
        self.listen(to: value)
    }
    
}
