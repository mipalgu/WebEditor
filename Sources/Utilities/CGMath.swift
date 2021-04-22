//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/4/21.
//

import Foundation

infix operator +: AdditionPrecedence
func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

infix operator -: AdditionPrecedence
func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

infix operator *: MultiplicationPrecedence
func *(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
}

infix operator /: MultiplicationPrecedence
func /(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
}

postfix operator <
postfix func <(value: CGPoint) -> CGFloat {
    CGFloat(atan2(Double(value.y), Double(value.x)) / Double.pi * 180.0)
}

postfix operator ||
postfix func ||(value: CGPoint) -> CGFloat {
    CGFloat(sqrt(Double(value.x * value.x) + Double(value.y * value.y)))
}

postfix operator ||<
postfix func ||<(value: CGPoint) -> (CGFloat, CGFloat) {
    (value||, value<)
}


