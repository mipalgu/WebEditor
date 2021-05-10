/*
 * TransitionLayout.swift
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

import Foundation

extension CGPoint: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
    
}

struct TransitionLayout: PlistConvertible, Hashable {
    
    enum CodingKeys: String, Hashable, CodingKey {
        
        case controlPoint1X
        case controlPoint1Y
        case controlPoint2X
        case controlPoint2Y
        case dstPointX
        case dstPointY
        case srcPointX
        case srcPointY
        
    }
    
    var srcPoint: CGPoint
    
    var dstPoint: CGPoint
    
    var controlPoint1: CGPoint
    
    var controlPoint2: CGPoint
    
    var plistRepresentation: String {
        return "" // Convert to plist xml here.
    }
    
    var curve: Curve {
        Curve(
            point0: srcPoint,
            point1: controlPoint1,
            point2: controlPoint2,
            point3: dstPoint
        )
    }
    
    init(curve: Curve) {
        self.init(srcPoint: curve.point0, dstPoint: curve.point3, controlPoint1: curve.point1, controlPoint2: curve.point2)
    }
    
    init(srcPoint: CGPoint, dstPoint: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        self.srcPoint = srcPoint
        self.dstPoint = dstPoint
        self.controlPoint1 = controlPoint1
        self.controlPoint2 = controlPoint2
    }
    
    // Potentially throws? -> init() throws {
    init?(fromPlistRepresentation str: String) {
        return nil // Convert from plist string here.
    }
    
}

extension TransitionLayout: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let controlPoint1X = try container.decode(CGFloat.self, forKey: .controlPoint1X)
        let controlPoint1Y = try container.decode(CGFloat.self, forKey: .controlPoint1Y)
        let controlPoint2X = try container.decode(CGFloat.self, forKey: .controlPoint2X)
        let controlPoint2Y = try container.decode(CGFloat.self, forKey: .controlPoint2Y)
        let dstPointX = try container.decode(CGFloat.self, forKey: .dstPointX)
        let dstPointY = try container.decode(CGFloat.self, forKey: .dstPointY)
        let srcPointX = try container.decode(CGFloat.self, forKey: .srcPointX)
        let srcPointY = try container.decode(CGFloat.self, forKey: .srcPointY)
        self.init(
            srcPoint: CGPoint(x: srcPointX, y: srcPointY),
            dstPoint: CGPoint(x: dstPointX, y: dstPointY),
            controlPoint1: CGPoint(x: controlPoint1X, y: controlPoint1Y),
            controlPoint2: CGPoint(x: controlPoint2X, y: controlPoint2Y)
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(controlPoint1.x, forKey: .controlPoint1X)
        try container.encode(controlPoint1.y, forKey: .controlPoint1Y)
        try container.encode(controlPoint2.x, forKey: .controlPoint2X)
        try container.encode(controlPoint2.y, forKey: .controlPoint2Y)
        try container.encode(dstPoint.x, forKey: .dstPointX)
        try container.encode(dstPoint.y, forKey: .dstPointY)
        try container.encode(srcPoint.x, forKey: .srcPointX)
        try container.encode(srcPoint.y, forKey: .srcPointY)
    }
    
}
