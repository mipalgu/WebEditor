//
//  EditorViewModel.swift
//  
//
//  Created by Morgan McColl on 21/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities

public class EditorViewModel: ObservableObject {
    
    @Published public var machine: MachineViewModel
    
    @Published public var mainView: ViewType = .machine
    
    @Published public var focusedView: ViewType = .machine
    
    @Published public var currentMachineIndex: Int
    
    @Published public var errorLog: [Error]
    
    @Published public var rightDividerLocation: CGFloat
    
    @Published var _leftDividerLocation: CGFloat
    
    var leftDividerLocation: CGFloat {
        get {
            if leftPaneCollapsed {
                return collapsedPaneWidth
            }
            return max(min(leftPaneMaxWidth, _leftDividerLocation), leftPaneMinWidth)
        } set {
            self._leftDividerLocation = max(min(leftPaneMaxWidth, newValue), leftPaneMinWidth)
        }
    }
    
    let dividerWidth: CGFloat = 5.0
    
    let rightPaneMaxWidth: CGFloat = 500
    
    let rightPaneMinWidth: CGFloat = 300
    
    let leftPaneMaxWidth: CGFloat = 500
    
    let leftPaneMinWidth: CGFloat = 300
    
    let mainViewMinWidth: CGFloat = 800
    
    let buttonHeight: CGFloat = 30.0
    
    let buttonWidth: CGFloat = 30.0
    
    let buttonSize: CGFloat = 20.0
    
    let collapsedPaneWidth: CGFloat = 50.0
    
    var editorMinWidth: CGFloat {
        rightPaneMinWidth + leftPaneMinWidth + 2.0 * dividerWidth + mainViewMinWidth
    }
    
    public let logSize: UInt16
    
    public var currentMachine: MachineViewModel {
        self.machine
    }
    
    var mainViewWidth: CGFloat {
        max(rightDividerLocation - dividerWidth - leftDividerLocation, mainViewMinWidth)
    }
    
    var leftPaneWidth: CGFloat {
        if leftPaneCollapsed {
            return collapsedPaneWidth
        }
        return max(min(leftPaneMaxWidth, leftDividerLocation - dividerWidth / 2.0), leftPaneMinWidth)
    }
    
    @Published var leftPaneCollapsed: Bool = false
    
    @Published var rightPaneCollapsed: Bool = false
    
    public var log: String {
        errorLog.map { $0.localizedDescription }.reduce("") {
            if $0 == "" {
                return $1
            }
            if $1 == "" {
                return $0
            }
            return $0 + "\n" + $1
        }
    }
    
    var draggingRight: Bool = false
    
    var draggingLeft: Bool = false
    
    var originalLocation: CGFloat = 0.0
    
    public init(machine: MachineViewModel, mainView: ViewType = .machine, focusedView: ViewType = .machine, currentMachineIndex: Int = 0, logSize: UInt16 = 50, rightDividerLocation: CGFloat = 0, leftDividerLocation: CGFloat = 0.0) {
        self.machine = machine
        self.mainView = mainView
        self.focusedView = focusedView
        self.currentMachineIndex = currentMachineIndex
        self.logSize = logSize
        self.rightDividerLocation = rightDividerLocation
        self._leftDividerLocation = leftDividerLocation
        self.errorLog = []
        self.errorLog.reserveCapacity(Int(logSize))
        self.listen(to: machine)
    }
    
    public func changeFocus(stateIndex: Int) {
        self.focusedView = .state(stateIndex: stateIndex)
    }
    
    public func changeFocus() {
        self.focusedView = .machine
    }
    
    public func changeMainView(stateIndex: Int) {
        self.mainView = .state(stateIndex: stateIndex)
    }
    
    public func changeMainView() {
        self.mainView = .machine
    }
    
//    public func machine(id: UUID) -> MachineViewModel? {
//        machines.first { $0.id == id }
//    }
//    
//    public func machineIndex(id: UUID) -> Int? {
//        machines.firstIndex(where: { $0.id == id })
//    }
    
//    func state(machine: UUID, stateIndex: Int) -> StateViewModel? {
//        guard let machine = self.machine(id: machine) else {
//            print("Machine is nil")
//            return nil
//        }
//        let states = machine.states
//        return states[stateIndex]
//    }
    
    public func addError(error: Error) {
        if errorLog.count > logSize {
            let _ = errorLog.popLast()
        }
        errorLog.insert(error, at: 0)
    }
    
    func getRightDividerLocation(width: CGFloat) -> CGFloat {
        if rightPaneCollapsed {
            return width - collapsedPaneWidth
        }
        return min(max(width - rightPaneMaxWidth - dividerWidth / 2.0, rightDividerLocation), width - rightPaneMinWidth - dividerWidth / 2.0)
    }
    
    func getMainViewWidth(width: CGFloat) -> CGFloat {
        let width1 = max(getRightDividerLocation(width: width) - dividerWidth - leftDividerLocation, mainViewMinWidth)
        return min(width1, width - rightPaneWidth(width: width) - dividerWidth - leftDividerLocation)
    }
    
    func dragRightDividor(width: CGFloat, gesture: DragGesture.Value) {
        if rightPaneCollapsed {
            return
        }
        if !draggingRight {
            originalLocation = rightDividerLocation
            draggingRight = true
            return
        }
        rightDividerLocation = min(max(width - rightPaneMaxWidth - dividerWidth / 2.0, originalLocation + gesture.translation.width), width - rightPaneMinWidth - dividerWidth / 2.0)
    }
    
    func finishDraggingRight(width: CGFloat, gesture: DragGesture.Value) {
        dragRightDividor(width: width, gesture: gesture)
        draggingRight = false
    }
    
    func dragLeftDividor(gesture: DragGesture.Value) {
        if leftPaneCollapsed {
            return
        }
        if !draggingLeft {
            originalLocation = leftDividerLocation
            draggingLeft = true
            return
        }
        leftDividerLocation = originalLocation + gesture.translation.width
    }
    
    func finishDraggingLeft(gesture: DragGesture.Value) {
        dragLeftDividor(gesture: gesture)
        draggingLeft = false
    }
    
    func rightPaneWidth(width: CGFloat) -> CGFloat {
        if rightPaneCollapsed {
            return collapsedPaneWidth
        }
        return min(max(width - getRightDividerLocation(width: width) - dividerWidth / 2.0, rightPaneMinWidth), rightPaneMaxWidth)
    }
    
    func rightPaneLocation(width: CGFloat) -> CGFloat {
        width - rightPaneWidth(width: width) / 2.0
    }
    
}
