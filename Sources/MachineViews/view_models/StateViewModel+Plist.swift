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

extension StateViewModel {
    
    convenience init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machines.State>, plist data: String) {
        let helper = StringHelper()
        let x = helper.getValueFromFloat(plist: data, label: "x")
        let y = helper.getValueFromFloat(plist: data, label: "y")
        let w = helper.getValueFromFloat(plist: data, label: "w")
        let h = helper.getValueFromFloat(plist: data, label: "h")
        let expanded = helper.getValueFromBool(plist: data, label: "expanded")
        let highlighted = helper.getValueFromBool(plist: data, label: "stateSelected")
        let transitionsPlist: String = data.components(separatedBy: "<key>Transitions</key>")[1].components(separatedBy: "<key>bgColour</key>")[0]
        let transitionViewModels = machine.value[keyPath: path.path].transitions.indices.map { (priority: Int) -> TransitionViewModel in
            let transitionPlist = transitionsPlist.components(separatedBy: "</dict>")[priority]
                .components(separatedBy: "<dict>")[1]
            return TransitionViewModel(machine: machine, state: path, priority: UInt8(priority), plist: transitionPlist)
        }
        self.init(machine: machine, path: path, location: CGPoint(x: x, y: y), width: w, height: h, expanded: expanded, collapsedWidth: 150.0, collapsedActions: [:], highlighted: highlighted, transitionViewModels: transitionViewModels)
    }
    
    fileprivate func colourPList() -> String {
        let helper = StringHelper()
        return "<dict>\n" +
            helper.tab(data: "<key>alpha</key>\n<real>1</real>\n<key>blue</key>\n<real>0.92000000000000004</real>" +
        "\n<key>green</key>\n<real>0.92000000000000004</real>\n<key>red</key>\n<real>0.92000000000000004</real>"
            )
            + "\n</dict>"
    }
    
    fileprivate func strokePlist() -> String {
        let helper = StringHelper()
        return "<dict>\n" +
            helper.tab(data: "<key>alpha</key>\n<real>1</real>\n<key>blue</key>\n<real>0.0</real>" +
        "\n<key>green</key>\n<real>0.0</real>\n<key>red</key>\n<real>0.0</real>"
            )
            + "\n</dict>"
    }
    
    fileprivate func boolToPlist(value: Bool) -> String {
        value ? "<true/>" : "<false/>"
    }
    
    fileprivate func actionHeightstoPList() -> String {
        let helper = StringHelper()
        return helper.reduceLines(data: actions.map {
            "<key>\($0.name)Height</key>\n<real>\(getHeightOfAction(actionName: $0.name))</real>"
        })
    }
    
    func toPList() -> String {
        let helper = StringHelper()
        let transitionPList = helper.reduceLines(data: transitionViewModels.map { $0.toPlist() })
        return "<key>\(name)</key>\n<dict>\n"
            + helper.tab(data: "<key>Transitions</key>\n\(transitions.count == 0 ? "<array/>" : "<array>")\n" +
                helper.tab(data: transitionPList) + "\(transitions.count == 0 ? "" : "\n</array>")" +
                "\n<key>bgColour</key>\n" + colourPList() + "\n<key>editingMode</key>\n<false/>\n" +
                "<key>expanded</key>\n\(boolToPlist(value: expanded))\n" +
                "<key>h</key>\n<real>\(height)</real>\n" + actionHeightstoPList() +
                "\n<key>stateSelected</key>\n\(boolToPlist(value: highlighted))\n<key>strokeColour</key>\n" +
                strokePlist() + "\n<key>w</key>\n<real>\(width)</real>\n<key>x</key>\n<real>\(location.x)</real>\n" +
                "<key>y</key>\n<real>\(location.y)</real>\n<key>zoomedInternalHeight</key>\n<real>0.0</real>\n" +
                "<key>zoomedOnEntryHeight</key>\n<real>0.0</real>\n<key>zoomedOnExitHeight</key>\n<real>0.0</real>"
            ) + "\n</dict>"
    }
    
}
