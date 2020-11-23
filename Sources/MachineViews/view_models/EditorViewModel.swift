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

public class EditorViewModel: ObservableObject {
    
    @Published public var machines: [MachineViewModel]
    
    @Published public var mainView: ViewType = .none
    
    @Published public var focusedView: ViewType = .none
    
    @Published public var currentMachineIndex: Int
    
    @Published public var errorLog: [Error]
    
    @Published public var rightDividerLocation: CGFloat
    
    @Published var _leftDividerLocation: CGFloat
    
    var leftDividerLocation: CGFloat {
        get {
            max(min(leftPaneMaxWidth, _leftDividerLocation), leftPaneMinWidth)
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
    
    var editorMinWidth: CGFloat {
        rightPaneMinWidth + leftPaneMinWidth + 2.0 * dividerWidth + mainViewMinWidth
    }
    
    public let logSize: UInt16
    
    public var currentMachine: MachineViewModel {
        machines[currentMachineIndex]
    }
    
    var mainViewWidth: CGFloat {
        max(rightDividerLocation - dividerWidth - leftDividerLocation, mainViewMinWidth)
    }
    
    var leftPaneWidth: CGFloat {
        max(min(leftPaneMaxWidth, leftDividerLocation - dividerWidth / 2.0), leftPaneMinWidth)
    }
    
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
    
    public init(machines: [MachineViewModel], mainView: ViewType = .none, focusedView: ViewType = .none, currentMachineIndex: Int = 0, logSize: UInt16 = 50, rightDividerLocation: CGFloat = 10000, leftDividerLocation: CGFloat = 0.0) {
        self.machines = machines
        self.mainView = mainView
        self.focusedView = focusedView
        self.currentMachineIndex = currentMachineIndex
        self.logSize = logSize
        self.rightDividerLocation = rightDividerLocation
        self._leftDividerLocation = leftDividerLocation
        self.errorLog = []
        self.errorLog.reserveCapacity(Int(logSize))
    }
    
    public func changeFocus(machine: UUID, stateIndex: Int) {
        guard nil != self.state(machine: machine, stateIndex: stateIndex) else {
            return
        }
        self.focusedView = .state(machine: machine, stateIndex: stateIndex)
    }
    
    public func changeFocus(machine: UUID) {
        guard nil != self.machine(id: machine) else {
            return
        }
        self.focusedView = .machine(id: machine)
    }
    
    public func changeMainView(machine: UUID, stateIndex: Int) {
        guard nil != self.state(machine: machine, stateIndex: stateIndex) else {
            return
        }
        self.mainView = .state(machine: machine, stateIndex: stateIndex)
    }
    
    public func changeMainView(machine: UUID) {
        guard nil != self.machine(id: machine) else {
            return
        }
        self.mainView = .machine(id: machine)
    }
    
    public func machine(id: UUID) -> MachineViewModel? {
        machines.first { $0.id == id }
    }
    
    public func state(machine: UUID, stateIndex: Int) -> StateViewModel? {
        self.machine(id: machine)?.states[stateIndex]
    }
    
    public func addError(error: Error) {
        if errorLog.count > logSize {
            let _ = errorLog.popLast()
        }
        errorLog.insert(error, at: 0)
    }
    
    func getRightDividerLocation(width: CGFloat) -> CGFloat {
        min(max(width - rightPaneMaxWidth - dividerWidth / 2.0, rightDividerLocation), width - rightPaneMinWidth - dividerWidth / 2.0)
    }
    
    func getMainViewWidth(width: CGFloat) -> CGFloat {
        min(mainViewWidth, width - rightPaneWidth(width: width) - dividerWidth - leftDividerLocation)
    }
    
    func dragRightDividor(width: CGFloat, gesture: DragGesture.Value) {
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
        min(max(width - rightDividerLocation - dividerWidth / 2.0, rightPaneMinWidth), rightPaneMaxWidth)
    }
    
    func rightPaneLocation(width: CGFloat) -> CGFloat {
        width - rightPaneWidth(width: width) / 2.0
    }
    
}
