//
//  File.swift
//  
//
//  Created by Morgan McColl on 17/4/21.
//

import TokamakShim

import Machines
import Attributes
import Transformations
import Utilities

struct StateViewModel2: MoveAndStretchFromDrag, _Collapsable, Collapsable, EdgeDetector, TextRepresentable, BoundedSize, _Rigidable {
    
    var isText: Bool
    
    var isDragging: Bool = false
    
    var _collapsedWidth: CGFloat
    
    var _collapsedHeight: CGFloat
    
    var expanded: Bool
    
    var location: CGPoint

    let collapsedMinWidth: CGFloat = 150.0
    
    let collapsedMaxWidth: CGFloat = 250.0
    
    let collapsedMinHeight: CGFloat = 100.0
    
    let collapsedMaxHeight: CGFloat = 125.0
    
    var _expandedWidth: CGFloat
    
    var _expandedHeight: CGFloat
    
    var offset: CGPoint = CGPoint.zero
    
    let expandedMinWidth: CGFloat = 200.0
    
    let expandedMaxWidth: CGFloat = 600.0
    
    let expandedMinHeight: CGFloat = 150.0
    
    var expandedMaxHeight: CGFloat = 300.0
    
    var isStretchingX: Bool = false
    
    var isStretchingY: Bool = false
    
    let _collapsedTolerance: CGFloat = 0
    
    let _expandedTolerance: CGFloat = 20.0
    
    var horizontalEdgeTolerance: CGFloat {
        expanded ? _expandedTolerance : _collapsedTolerance
    }
    
    var verticalEdgeTolerance: CGFloat {
        horizontalEdgeTolerance
    }
    
    var collapsedActions: [String: Bool] = [:]
    
    public init(location: CGPoint = CGPoint(x: 75, y: 100), expandedWidth: CGFloat = 75.0, expandedHeight: CGFloat = 100.0, expanded: Bool = false, collapsedWidth: CGFloat = 150.0, collapsedHeight: CGFloat = 100.0, isText: Bool = false) {
        self.location = location
        self._expandedWidth = expandedWidth
        self._expandedHeight = expandedHeight
        self.expanded = expanded
        self._collapsedWidth = collapsedWidth
        self._collapsedHeight = collapsedHeight
        self.isText = isText
    }
    
    mutating func toggleExpand(frameWidth: CGFloat, frameHeight: CGFloat) {
        self.expanded = !self.expanded
        let newLocation: CGPoint
        if self.expanded {
            newLocation = CGPoint(
                x: self.location.x,
                y: self.location.y + collapsedHeight / 2.0
            )
        } else {
            newLocation = CGPoint(
                x: self.location.x,
                y: self.location.y - expandedHeight / 2.0
            )
        }
        self.setLocation(width: frameWidth, height: frameHeight, newLocation: newLocation)
    }

}

extension StateViewModel2 {

    init(plist data: String) {
        let helper = StringHelper()
        let x = helper.getValueFromFloat(plist: data, label: "x")
        let y = helper.getValueFromFloat(plist: data, label: "y")
        let w = helper.getValueFromFloat(plist: data, label: "w")
        let h = helper.getValueFromFloat(plist: data, label: "h")
        let expanded = helper.getValueFromBool(plist: data, label: "expanded")
//        let highlighted = helper.getValueFromBool(plist: data, label: "stateSelected")
//        let transitionsPlist: String = data.components(separatedBy: "<key>Transitions</key>")[1].components(separatedBy: "<key>bgColour</key>")[0]
//        let transitionViewModels = transitions.indices.map { (priority: Int) -> TransitionViewModel2 in
//            let transitionPlist = transitionsPlist.components(separatedBy: "</dict>")[priority]
//                .components(separatedBy: "<dict>")[1]
//            return TransitionViewModel2(plist: transitionPlist)
//        }
        self.init(
            location: CGPoint(x: x, y: y),
            expandedWidth: CGFloat(w),
            expandedHeight: CGFloat(h),
            expanded: expanded,
            collapsedWidth: 150.0,
            collapsedHeight: 100.0,
            isText: false
        )
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

    fileprivate func actionHeightstoPList(state: Machines.State) -> String {
        let helper = StringHelper()
        return helper.reduceLines(data: state.actions.map {
            "<key>\($0.name)Height</key>\n<real>\(100.0)</real>"
        })
    }

    func toPList(transitionViewModels: [TransitionViewModel2], state: Machines.State) -> String {
        let helper = StringHelper()
        let transitionPList = helper.reduceLines(data: transitionViewModels.map { $0.toPlist() })
        return "<key>\(state.name)</key>\n<dict>\n"
            + helper.tab(data: "<key>Transitions</key>\n\(state.transitions.count == 0 ? "<array/>" : "<array>")\n" +
                            helper.tab(data: transitionPList) + "\(state.transitions.count == 0 ? "" : "\n</array>")" +
                "\n<key>bgColour</key>\n" + colourPList() + "\n<key>editingMode</key>\n<false/>\n" +
                "<key>expanded</key>\n\(boolToPlist(value: expanded))\n" +
                            "<key>h</key>\n<real>\(height)</real>\n" + actionHeightstoPList(state: state) +
                "\n<key>stateSelected</key>\n\(boolToPlist(value: false))\n<key>strokeColour</key>\n" +
                strokePlist() + "\n<key>w</key>\n<real>\(width)</real>\n<key>x</key>\n<real>\(location.x)</real>\n" +
                "<key>y</key>\n<real>\(location.y)</real>\n<key>zoomedInternalHeight</key>\n<real>0.0</real>\n" +
                "<key>zoomedOnEntryHeight</key>\n<real>0.0</real>\n<key>zoomedOnExitHeight</key>\n<real>0.0</real>"
            ) + "\n</dict>"
    }

}
