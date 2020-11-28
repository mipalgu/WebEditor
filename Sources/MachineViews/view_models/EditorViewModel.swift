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

public class EditorViewModel: ObservableObject, Hashable {
    
    public static func == (lhs: EditorViewModel, rhs: EditorViewModel) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(machine)
    }
    
    @Published public var machine: MachineViewModel
    
    @Published public var mainView: ViewType = .machine
    
    @Published public var focusedView: ViewType = .machine
    
    @Published var paneCollapsed: Bool = false
    
    @Published var dividerViewModel: BoundedPositionViewModel
    
    @Published var dialogueType: DialogueViewType = .none
    
    var dividerWidth: CGFloat {
        dividerViewModel.width
    }
    
    let rightPaneMaxWidth: CGFloat = 500
    
    let rightPaneMinWidth: CGFloat = 300
    
    let mainViewMinWidth: CGFloat = 800
    
    let buttonWidth: CGFloat = 30.0
    
    let buttonSize: CGFloat = 20.0
    
    let collapsedPaneWidth: CGFloat = 50.0
    
    private var mainViewWidth: CGFloat {
        max(dividerLocation.x - dividerWidth, mainViewMinWidth)
    }
    
    var dividerMinX: CGFloat {
        mainViewMinWidth + dividerWidth / 2.0
    }
    
    private var dividerLocation: CGPoint {
        dividerViewModel.location
    }
    
    var panelLabel: String {
        machine.name + " Machine Attributes"
    }
    
    var collapsedBinding: Binding<Bool> {
        Binding(get: { self.paneCollapsed }, set: { self.paneCollapsed = $0 })
    }
    
    var focusedViewBinding: Binding<ViewType> {
        Binding(get: { self.focusedView }, set: { self.focusedView = $0 })
    }
    
    var mainViewBinding: Binding<ViewType> {
        Binding(get: { self.mainView }, set: { self.mainView = $0 })
    }

    public init(machine: MachineViewModel, mainView: ViewType = .machine, focusedView: ViewType = .machine, dividerViewModel: BoundedPositionViewModel) {
        self.machine = machine
        self.mainView = mainView
        self.focusedView = focusedView
        self.dividerViewModel = dividerViewModel
        self.listen(to: machine)
        self.listen(to: dividerViewModel)
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
    
    func getMainViewWidth(width: CGFloat) -> CGFloat {
        let width1 = getDividerLocation(width: width, height: .infinity).x - dividerWidth / 2.0
        return max(min(width1, width - paneWidth(width: width) - dividerWidth), mainViewMinWidth)
    }
    
    func paneWidth(width: CGFloat) -> CGFloat {
        if paneCollapsed {
            return collapsedPaneWidth
        }
        return min(
            max(width - getDividerLocation(width: width, height: .infinity).x - dividerWidth / 2.0, rightPaneMinWidth),
            rightPaneMaxWidth
        )
    }
    
    func paneLocation(width: CGFloat, height: CGFloat) -> CGPoint {
        let x = getDividerLocation(width: width, height: height).x + dividerWidth / 2.0 + paneWidth(width: width) / 2.0
        return CGPoint(x: x, y: height / 2.0)
    }
    
    func dividerMaxX(width: CGFloat) -> CGFloat {
        width - rightPaneMaxWidth - dividerWidth / 2.0
    }
    
    func getDividerLocation(width: CGFloat, height: CGFloat) -> CGPoint {
        if paneCollapsed {
            return CGPoint(x: width - collapsedPaneWidth, y: height / 2.0)
        }
        let x = min(max(width - rightPaneMaxWidth - dividerWidth / 2.0, dividerLocation.x), width - rightPaneMinWidth - dividerWidth / 2.0)
        return CGPoint(x: x, y: height / 2.0)
    }

}
