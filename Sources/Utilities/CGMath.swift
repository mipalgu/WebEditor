//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/4/21.
//

import Foundation

infix operator +: AdditionPrecedence
public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

infix operator -: AdditionPrecedence
public func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

infix operator *: MultiplicationPrecedence
public func *(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
}

infix operator /: MultiplicationPrecedence
public func /(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
}

public func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
}

postfix operator <
public postfix func <(value: CGPoint) -> CGFloat {
    CGFloat(atan2(Double(value.y), Double(value.x)) / Double.pi * 180.0)
}

postfix operator ||
public postfix func ||(value: CGPoint) -> CGFloat {
    CGFloat(sqrt(Double(value.x * value.x) + Double(value.y * value.y)))
}

postfix operator ||<
public postfix func ||<(value: CGPoint) -> (CGFloat, CGFloat) {
    (value||, value<)
}

public func normalise(degrees: CGFloat) -> CGFloat {
    let normalisedDegrees = degrees.truncatingRemainder(dividingBy: 360.0)
    return normalisedDegrees > 180.0 ? normalisedDegrees - 360.0 : normalisedDegrees
}

public func normalise(radians: CGFloat) -> CGFloat {
    deg2rad(degrees: normalise(degrees: rad2deg(radians: radians)))
}

public func rad2deg(radians: CGFloat) -> CGFloat {
    CGFloat(Double(radians) / Double.pi * 180.0)
}

public func deg2rad(degrees: CGFloat) -> CGFloat {
    CGFloat(Double(degrees / 180.0) * Double.pi)
}

public func width(point0: CGPoint, point1: CGPoint) -> CGFloat {
    abs(point1.x - point0.x)
}

public func height(point0: CGPoint, point1: CGPoint) -> CGFloat {
    abs(point1.y - point0.y)
}

public func center(point0: CGPoint, point1: CGPoint) -> CGPoint {
    point0 + (point1 - point0) / 2.0
}


