//
//  StateTracker.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import Foundation
import TokamakShim
import Transformations
import Machines
import Utilities

class StateTracker: MoveAndStretchFromDrag, _Collapsable, Collapsable, EdgeDetector, TextRepresentable, BoundedSize, _Rigidable, ObservableObject {
    
    @Published var isText: Bool {
        didSet {
            guard let notifier = notifier else {
                return
            }
            notifier.send()
        }
    }
    
    var isDragging: Bool = false
    
    @Published var _collapsedWidth: CGFloat {
        didSet {
            guard let notifier = notifier else {
                return
            }
            notifier.send()
        }
    }
    
    @Published var _collapsedHeight: CGFloat {
        didSet {
            guard let notifier = notifier else {
                return
            }
            notifier.send()
        }
    }
    
    @Published var expanded: Bool {
        didSet {
            guard let notifier = notifier else {
                return
            }
            notifier.send()
        }
    }
    
    @Published var location: CGPoint

    let collapsedMinWidth: CGFloat = 150.0
    
    let collapsedMaxWidth: CGFloat = 250.0
    
    let collapsedMinHeight: CGFloat = 100.0
    
    let collapsedMaxHeight: CGFloat = 125.0
    
    @Published var _expandedWidth: CGFloat {
        didSet {
            guard let notifier = notifier else {
                return
            }
            notifier.send()
        }
    }
    
    @Published var _expandedHeight: CGFloat {
        didSet {
            guard let notifier = notifier else {
                return
            }
            notifier.send()
        }
    }
    
    var offset: CGPoint = CGPoint.zero
    
    let expandedMinWidth: CGFloat = 200.0
    
    let expandedMaxWidth: CGFloat = 600.0
    
    let expandedMinHeight: CGFloat = 150.0
    
    var expandedMaxHeight: CGFloat = 300.0
    
    var isStretchingX: Bool = false
    
    var isStretchingY: Bool = false
    
    let _collapsedTolerance: CGFloat = 0
    
    let _expandedTolerance: CGFloat = 20.0
    
    var notifier: GlobalChangeNotifier?
    
    var horizontalEdgeTolerance: CGFloat {
        expanded ? _expandedTolerance : _collapsedTolerance
    }
    
    var verticalEdgeTolerance: CGFloat {
        horizontalEdgeTolerance
    }
    
    init(location: CGPoint = CGPoint(x: 75, y: 100), expandedWidth: CGFloat = 75.0, expandedHeight: CGFloat = 100.0, expanded: Bool = false, collapsedWidth: CGFloat = 150.0, collapsedHeight: CGFloat = 100.0, isText: Bool = false, notifier: GlobalChangeNotifier? = nil) {
        self.location = location
        self._expandedWidth = expandedWidth
        self._expandedHeight = expandedHeight
        self.expanded = expanded
        self._collapsedWidth = collapsedWidth
        self._collapsedHeight = collapsedHeight
        self.isText = isText
        self.notifier = notifier
    }
    
    func toggleExpand(frameWidth: CGFloat, frameHeight: CGFloat) {
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

extension StateTracker {

    convenience init(plist data: String, notifier: GlobalChangeNotifier? = nil) {
//        let transitions = state.transitions
        let helper = StringHelper()
        let x = helper.getValueFromFloat(plist: data, label: "x")
        let y = helper.getValueFromFloat(plist: data, label: "y")
        let w = helper.getValueFromFloat(plist: data, label: "w")
        let h = helper.getValueFromFloat(plist: data, label: "h")
        let expanded = helper.getValueFromBool(plist: data, label: "expanded")
//        let highlighted = helper.getValueFromBool(plist: data, label: "stateSelected")
//        let transitionsPlist: String = data.components(separatedBy: "<key>Transitions</key>")[1].components(separatedBy: "<key>bgColour</key>")[0]
//        let transitionViewModels = transitions.indices.map { (priority: Int) -> TransitionViewModel in
//            let transitionPlist = transitionsPlist.components(separatedBy: "</dict>")[priority]
//                .components(separatedBy: "<dict>")[1]
//            return TransitionViewModel(machine: machine, path: path.transitions[priority], transitionBinding: state.transitions[priority], plist: transitionPlist)
//        }
        self.init(
            location: CGPoint(x: x, y: y),
            expandedWidth: expanded ? w : 75.0,
            expandedHeight: expanded ? h : 100.0,
            expanded: expanded,
            collapsedWidth: expanded ? 150.0 : w,
            collapsedHeight: expanded ? 100.0 : h,
            isText: false,
            notifier: notifier
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
//
//    func plist(state: Machines.State) -> String {
//        let helper = StringHelper()
//        let transitionPList = helper.reduceLines(data: transitions.map { $0.toPlist() })
//        return "<key>\(state.wrappedValue.name)</key>\n<dict>\n"
//            + helper.tab(data: "<key>Transitions</key>\n\(transitions.count == 0 ? "<array/>" : "<array>")\n" +
//                            helper.tab(data: transitionPList) + "\(transitions.count == 0 ? "" : "\n</array>")" +
//                "\n<key>bgColour</key>\n" + colourPList() + "\n<key>editingMode</key>\n<false/>\n" +
//                            "<key>expanded</key>\n\(boolToPlist(value: tracker.expanded))\n" +
//                            "<key>h</key>\n<real>\(tracker.height)</real>\n" + actionHeightstoPList(state: state.wrappedValue) +
//                "\n<key>stateSelected</key>\n\(boolToPlist(value: false))\n<key>strokeColour</key>\n" +
//                            strokePlist() + "\n<key>w</key>\n<real>\(tracker.width)</real>\n<key>x</key>\n<real>\(tracker.location.x)</real>\n" +
//                            "<key>y</key>\n<real>\(tracker.location.y)</real>\n<key>zoomedInternalHeight</key>\n<real>0.0</real>\n" +
//                "<key>zoomedOnEntryHeight</key>\n<real>0.0</real>\n<key>zoomedOnExitHeight</key>\n<real>0.0</real>"
//            ) + "\n</dict>"
//    }

}
