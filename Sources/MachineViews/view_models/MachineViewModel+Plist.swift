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

extension MachineViewModel {
    
    public convenience init(machine: Ref<Machine>, plist data: String) {
        let f: (CGPoint, StateViewModel) -> CGPoint = { (point: CGPoint, state: StateViewModel) in
            let dx = point.x - state.location.x
            let dy = point.y - state.location.y
            let degrees = CGFloat(atan2(Double(dy), Double(dx)) / Double.pi * 180.0)
            let normalisedDegrees = degrees.truncatingRemainder(dividingBy: 360.0)
            let theta = normalisedDegrees > 180.0 ? normalisedDegrees - 360.0 : normalisedDegrees
            if theta == 0.0 {
                return state.right
            }
            if theta == 90.0 {
                return state.bottom
            }
            if theta == -90.0 {
                return state.top
            }
            if theta == 180.0 || theta == -180.0 {
                return state.left
            }
            if state.expanded {
                //Rectangle
                var x: CGFloat = 0
                var y: CGFloat = 0
                let angle = Double(theta / 180.0) * Double.pi
                if theta >= -45.0 && theta <= 45.0 {
                    x = state.right.x
                    y = state.location.y + x * CGFloat(tan(angle))
                } else if theta <= 135.0 && theta >= 45.0 {
                    y = state.bottom.y
                    x = state.location.x + y / CGFloat(tan(angle))
                } else if theta < 180.0 && theta > 135.0 {
                    x = state.left.x
                    y = state.location.y - x * CGFloat(tan(angle))
                } else if theta > -135.0 {
                    y = state.top.y
                    x = state.location.x - y / CGFloat(tan(angle))
                } else {
                    x = state.left.x
                    y = state.location.y - x * CGFloat(tan(angle))
                }
                return CGPoint(x: min(max(state.left.x, x), state.right.x), y: min(max(y, state.top.y), state.bottom.y))
            }
            //Ellipse
            let radians = Double(theta) / 180.0 * Double.pi
            let tanr = tan(radians)
            let a = state.collapsedWidth / 2.0
            let b = state.collapsedHeight / 2.0
            var x: CGFloat = CGFloat(Double(a * b) /
                sqrt(Double(b * b) + Double(a * a) * tanr * tanr))
            var y: CGFloat = CGFloat(Double(a * b) * tanr /
                sqrt(Double(b * b) + Double(a * a) * tanr * tanr))
            if radians > Double.pi / 2.0 || radians < -Double.pi / 2.0 {
                x = -x
                y = -y
            }
            x = state.location.x + x
            y = state.location.y + y
            return CGPoint(x: x, y: y)
        }
        
        let stateViewModels = machine.value.states.indices.map { (stateIndex: Int) -> StateViewModel in
            let stateName = machine.value.states[stateIndex].name
            let statePlist: String = data.components(separatedBy: "<key>\(stateName)</key>")[1]
                .components(separatedBy: "<key>zoomedOnExitHeight</key>")[0]
            return StateViewModel(machine: machine, path: machine.value.path.states[stateIndex], plist: statePlist)
        }
        stateViewModels.forEach { stateVM in
            let externalTransitions: [TransitionViewModel] = stateViewModels.flatMap {
                $0.transitionViewModels.filter { $0.transition.target == stateVM.name }
            }
            externalTransitions.forEach {
                $0.point3 = f($0.point3, stateVM)
            }
            stateVM.transitionViewModels.forEach {
                $0.point0 = f($0.point0, stateVM)
            }
        }
        self.init(machine: machine, states: stateViewModels)
    }
    
    public func toPlist() -> String {
        let helper = StringHelper()
        let statesPlist = helper.reduceLines(data: states.map { $0.toPList() })
        return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
        "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" +
            "<plist version=\"1.0\">\n<dict>\n" + helper.tab(
                data: "<key>States</key>\n<dict>\n" + helper.tab(data: statesPlist) + "\n</dict>\n<key>Version</key>\n<string>1.3</string>"
            ) +
        "\n</dict>\n</plist>"
    }
    
}
