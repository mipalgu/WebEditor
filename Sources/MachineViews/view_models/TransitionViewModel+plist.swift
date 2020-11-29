//
//  File.swift
//  
//
//  Created by Morgan McColl on 25/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities

extension TransitionViewModel {

    convenience init(machine: Ref<Machine>, state: Attributes.Path<Machine, Machines.State>, priority: UInt8, plist data: String) {
        let helper = StringHelper()
        let path = state.transitions[Int(priority)]
        let point0X = helper.getValueFromFloat(plist: data, label: "srcPointX")
        let point0Y = helper.getValueFromFloat(plist: data, label: "srcPointY")
        let point1X = helper.getValueFromFloat(plist: data, label: "controlPoint1X")
        let point1Y = helper.getValueFromFloat(plist: data, label: "controlPoint1Y")
        let point2X = helper.getValueFromFloat(plist: data, label: "controlPoint2X")
        let point2Y = helper.getValueFromFloat(plist: data, label: "controlPoint2Y")
        let point3X = helper.getValueFromFloat(plist: data, label: "dstPointX")
        let point3Y = helper.getValueFromFloat(plist: data, label: "dstPointY")
        self.init(
            machine: machine,
            path: path,
            point0: CGPoint(x: point0X, y: point0Y),
            point1: CGPoint(x: point1X, y: point1Y),
            point2: CGPoint(x: point2X, y: point2Y),
            point3: CGPoint(x: point3X, y: point3Y),
            priority: priority
        )
    }
    
    fileprivate func floatToPList(key: String, point: CGFloat) -> String {
        return "<key>\(key)</key>\n<real>\(point)</real>\n"
    }
    
    func toPlist() -> String {
        let helper = StringHelper()
        return "<dict>\n" + helper.tab(
            data: floatToPList(key: "controlPoint1X", point: point1.x) +
                floatToPList(key: "controlPoint1Y", point: point1.y) +
                floatToPList(key: "controlPoint2X", point: point2.x) +
                floatToPList(key: "controlPoint2Y", point: point2.y) +
                floatToPList(key: "dstPointX", point: point3.x) +
                floatToPList(key: "dstPointY", point: point3.y) +
                floatToPList(key: "srcPointX", point: point0.x) +
                floatToPList(key: "srcPointY", point: point0.y)
        ) + "</dict>"
    }
    
}
