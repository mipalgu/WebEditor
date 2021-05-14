//
//  StateTracker.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import Foundation
import TokamakShim
import Transformations
import AttributeViews
import Machines
import Utilities

class StateTracker: MoveAndStretchFromDrag, _Collapsable, Collapsable, EdgeDetector, TextRepresentable, BoundedSize, _Rigidable, ObservableObject, Identifiable {
    
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

    let collapsedMinWidth: CGFloat = 100.0
    
    let collapsedMaxWidth: CGFloat = 250.0
    
    let collapsedMinHeight: CGFloat = 50.0
    
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
    
    weak var notifier: GlobalChangeNotifier?
    
    var horizontalEdgeTolerance: CGFloat {
        expanded ? _expandedTolerance : _collapsedTolerance
    }
    
    var verticalEdgeTolerance: CGFloat {
        horizontalEdgeTolerance
    }
    
    init(location: CGPoint = CGPoint(x: 75, y: 100), expandedWidth: CGFloat = 75.0, expandedHeight: CGFloat = 100.0, expanded: Bool = false, collapsedWidth: CGFloat = 100.0, collapsedHeight: CGFloat = 50.0, isText: Bool = false, notifier: GlobalChangeNotifier? = nil) {
        self.location = location
        self._expandedWidth = expandedWidth
        self._expandedHeight = expandedHeight
        self.expanded = expanded
        self._collapsedWidth = collapsedWidth
        self._collapsedHeight = collapsedHeight
        self.isText = isText
        self.notifier = notifier
    }
    
    convenience init(layout: StateLayout?, isText: Bool = false, notifier: GlobalChangeNotifier? = nil) {
        guard let layout = layout else {
            self.init()
            return
        }
        let location = CGPoint(x: layout.x, y: layout.y)
        let expanded = layout.expanded
        self.init(location: location, expanded: expanded, isText: isText, notifier: notifier)
    }
    
    func layout(transitions: [TransitionLayout], actions: [String], bgColor: SRGBColor, editingMode: Bool, stateSelected: Bool, strokeColor: SRGBColor) -> StateLayout {
        StateLayout(
            transitions: transitions,
            bgColor: bgColor,
            editingMode: editingMode,
            expanded: expanded,
            actionHeights: Dictionary(uniqueKeysWithValues: actions.map { ($0, 0) }),
            stateSelected: stateSelected,
            strokeColor: strokeColor,
            width: width,
            height: height,
            x: location.x,
            y: location.y,
            zoomedActionHeights: Dictionary(uniqueKeysWithValues: actions.map { ($0, 0) })
        )
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
