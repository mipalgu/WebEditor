/*
 * StateLayout.swift
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

struct SRGBColor: Hashable, Codable {
    
    enum CodingKeys: CodingKey {
        
        case alpha
        case blue
        case green
        case red
        
    }
    
    var alpha: CGFloat
    
    var red: CGFloat
    
    var green: CGFloat
    
    var blue: CGFloat
    
    init(alpha: CGFloat = 1.0, red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.alpha = alpha
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let alpha = try container.decode(CGFloat.self, forKey: .alpha)
        let blue = try container.decode(CGFloat.self, forKey: .blue)
        let green = try container.decode(CGFloat.self, forKey: .green)
        let red = try container.decode(CGFloat.self, forKey: .red)
        self.init(alpha: alpha, red: red, green: green, blue: blue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(alpha, forKey: .alpha)
        try container.encode(blue, forKey: .blue)
        try container.encode(green, forKey: .green)
        try container.encode(red, forKey: .red)
    }
    
}

struct StateLayout: PlistConvertible, Hashable {
    
    var transitions: [TransitionLayout]
    
    var bgColor: SRGBColor
    
    var editingMode: Bool
    
    var expanded: Bool
    
    var actionHeights: [String: CGFloat]
    
    var stateSelected: Bool
    
    var strokeColor: SRGBColor
    
    var width: CGFloat
    
    var height: CGFloat
    
    var x: CGFloat
    
    var y: CGFloat
    
    var zoomedActionHeights: [String: CGFloat]
    
    var plistRepresentation: String {
        return ""
    }
    
    init(transitions: [TransitionLayout], bgColor: SRGBColor, editingMode: Bool, expanded: Bool, actionHeights: [String: CGFloat], stateSelected: Bool, strokeColor: SRGBColor, width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat, zoomedActionHeights: [String: CGFloat]) {
        self.transitions = transitions
        self.bgColor = bgColor
        self.editingMode = editingMode
        self.expanded = expanded
        self.actionHeights = actionHeights
        self.stateSelected = stateSelected
        self.strokeColor = strokeColor
        self.width = width
        self.height = height
        self.x = x
        self.y = y
        self.zoomedActionHeights = zoomedActionHeights
    }
    
    init?(fromPlistRepresentation str: String) {
        return nil
    }
    
    struct CodingKeys: CodingKey, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
        
        var stringValue: String
        
        var intValue: Int? {
            Int(stringValue)
        }
        
        init(stringLiteral value: StringLiteralType) {
            self.stringValue = String(stringLiteral: value)
        }
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init(integerLiteral value: IntegerLiteralType) {
            self.stringValue = "\(Int(integerLiteral: value))"
        }
        
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
        }
        
    }
    
}

extension StateLayout: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let transitions = try container.decode([TransitionLayout].self, forKey: "Transitions")
        let bgColor = try container.decode(SRGBColor.self, forKey: "bgColour")
        let editingMode = try container.decode(Bool.self, forKey: "editingMode")
        let expanded = try container.decode(Bool.self, forKey: "expanded")
        let height = try container.decode(CGFloat.self, forKey: "h")
        let stateSelected = try container.decode(Bool.self, forKey: "stateSelected")
        let strokeColor = try container.decode(SRGBColor.self, forKey: "strokeColour")
        let width = try container.decode(CGFloat.self, forKey: "w")
        let x = try container.decode(CGFloat.self, forKey: "x")
        let y = try container.decode(CGFloat.self, forKey: "y")
        var actionHeights: [String: CGFloat] = [:]
        var zoomedActionHeights: [String: CGFloat] = [:]
        for key in container.allKeys where key.stringValue.hasSuffix("Height") {
            let name = key.stringValue.dropLast("Height".count)
            if name.hasPrefix("zoomed") {
                zoomedActionHeights[String(name.dropFirst("zoomed".count))] = try container.decode(CGFloat.self, forKey: key)
            } else {
                actionHeights[String(name)] = try container.decode(CGFloat.self, forKey: key)
            }
        }
        self.init(
            transitions: transitions,
            bgColor: bgColor,
            editingMode: editingMode,
            expanded: expanded,
            actionHeights: actionHeights,
            stateSelected: stateSelected,
            strokeColor: strokeColor,
            width: width,
            height: height,
            x: x,
            y: y,
            zoomedActionHeights: zoomedActionHeights
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(transitions, forKey: "Transitions")
        try container.encode(bgColor, forKey: "bgColour")
        try container.encode(editingMode, forKey: "editingMode")
        try container.encode(expanded, forKey: "expanded")
        try container.encode(height, forKey: "h")
        for (action, height) in actionHeights.sorted(by: { $0.key < $1.key }) {
            try container.encode(height, forKey: CodingKeys(stringValue: "\(action)Height")!)
        }
        try container.encode(stateSelected, forKey: "stateSelected")
        try container.encode(strokeColor, forKey: "strokeColour")
        try container.encode(width, forKey: "w")
        try container.encode(x, forKey: "x")
        try container.encode(y, forKey: "y")
        for (action, height) in zoomedActionHeights.sorted(by: { $0.key < $1.key }) {
            try container.encode(height, forKey: CodingKeys(stringValue: "zoomed\(action)Height")!)
        }
    }
    
}
