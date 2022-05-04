/*
 * StrokeView.swift
 * 
 *
 * Created by Callum McColl on 11/5/21.
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
import Utilities

struct StrokeView: View {
    
    @Binding var curve: Curve
    
    let strokeNumber: UInt8
    
    @EnvironmentObject var config: Config
    
    var strokeTheta: Double {
        atan2(Double(curve.point1.y - curve.point0.y), Double(curve.point1.x - curve.point0.x))
    }
    
    func getStrokeCenter(number: UInt8) -> CGPoint {
        let offset = 3.0 + 3.0 * Double(number)
        return CGPoint(x: curve.point0.x + CGFloat(offset * cos(strokeTheta)), y: curve.point0.y + CGFloat(offset * sin(strokeTheta)))
    }
    
    func strokePoint0(number: UInt8) -> CGPoint {
        let center = getStrokeCenter(number: number)
        let point1Theta = strokeTheta + Double.pi / 2.0
        let length = 2.0 + 2.0 * Double(max(number - 1, 0))
        return CGPoint(x: center.x + CGFloat(length * cos(point1Theta)), y: center.y + CGFloat(length * sin(point1Theta)))
    }
    
    func strokePoint1(number: UInt8) -> CGPoint {
        let center = getStrokeCenter(number: number)
        let point1Theta = strokeTheta - Double.pi / 2.0
        let length = 2.0 + 2.0 * Double(max(number - 1, 0))
        return CGPoint(x: center.x + CGFloat(length * cos(point1Theta)), y: center.y + CGFloat(length * sin(point1Theta)))
    }
    
    var body: some View {
        if strokeNumber > 0 {
            ForEach(1...strokeNumber, id: \.self) { number in
                Path { strokePath in
                    strokePath.move(to: strokePoint0(number: number))
                    strokePath.addLine(to: strokePoint1(number: number))
                }
                .stroke(config.textColor, lineWidth: 2)
                .border(Color.black, width: 2)
                //.coordinateSpace(name: "MAIN_VIEW")
            }
        }
    }
    
}
