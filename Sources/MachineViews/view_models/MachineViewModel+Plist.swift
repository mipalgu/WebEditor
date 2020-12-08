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
                $0.point3 = stateVM.findEdge(point: $0.point3)
            }
            stateVM.transitionViewModels.forEach {
                $0.point0 = stateVM.findEdge(point: $0.point0)
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
