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
    
    @Published public var machine: MachineViewModel
    
    @Published public var mainView: ViewType = .machine
    
    @Published public var focusedView: ViewType = .machine
    
    @Published public var currentMachineIndex: Int
    
    @Published public var errorLog: [Error]
    
    @Published public var rightDividerLocation: CGFloat
    

    
    
    
    let dividerWidth: CGFloat = 5.0
    
    let rightPaneMaxWidth: CGFloat = 500
    
    let rightPaneMinWidth: CGFloat = 300
    
    let mainViewMinWidth: CGFloat = 800
    
    let buttonWidth: CGFloat = 30.0
    

    
    var mainViewWidth: CGFloat {
        max(rightDividerLocation - dividerWidth, mainViewMinWidth)
    }
    
    @Published var paneCollapsed: Bool = false
    
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
    
    public init(machine: MachineViewModel, mainView: ViewType = .machine, focusedView: ViewType = .machine, currentMachineIndex: Int = 0, rightDividerLocation: CGFloat = 10000) {
        self.machine = machine
        self.mainView = mainView
        self.focusedView = focusedView
        self.currentMachineIndex = currentMachineIndex
        self.rightDividerLocation = rightDividerLocation
        self.errorLog = []
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
    
    /*public func addError(error: Error) {
        if errorLog.count > logSize {
            let _ = errorLog.popLast()
        }
        errorLog.insert(error, at: 0)
    }*/
    
    
    
    /*func getMainViewWidth(width: CGFloat) -> CGFloat {
        let width1 = max(getRightDividerLocation(width: width) - dividerWidth - leftDividerLocation, mainViewMinWidth)
        return min(width1, width - rightPaneWidth(width: width) - dividerWidth - leftDividerLocation)
    }*/
    
    /*func dragRightDividor(width: CGFloat, gesture: DragGesture.Value) {
        if rightPaneCollapsed {
            return
        }
        if !draggingRight {
            originalLocation = rightDividerLocation
            draggingRight = true
            return
        }
        rightDividerLocation = min(max(width - rightPaneMaxWidth - dividerWidth / 2.0, originalLocation + gesture.translation.width), width - rightPaneMinWidth - dividerWidth / 2.0)
    }*/
    
    /*func finishDraggingRight(width: CGFloat, gesture: DragGesture.Value) {
        dragRightDividor(width: width, gesture: gesture)
        draggingRight = false
    }*/
    
    
    
    /*func finishDraggingLeft(gesture: DragGesture.Value) {
        dragLeftDividor(gesture: gesture)
        draggingLeft = false
    }*/
    
    /*func paneWidth(width: CGFloat) -> CGFloat {
        if collapsed {
            return collapsedPaneWidth
        }
        return min(max(width - getRightDividerLocation(width: width) - dividerWidth / 2.0, rightPaneMinWidth), rightPaneMaxWidth)
    }*/
    
    /*func paneLocation(width: CGFloat) -> CGFloat {
        width - paneWidth(width: width) / 2.0
    }*/
    
    let collapsedPaneWidth: CGFloat = 50.0
    
    /*func getRightDividerLocation(width: CGFloat) -> CGFloat {
        if rightPaneCollapsed {
            return width - collapsedPaneWidth
        }
        return min(max(width - rightPaneMaxWidth - dividerWidth / 2.0, rightDividerLocation), width - rightPaneMinWidth - dividerWidth / 2.0)
    }*/
    
}
