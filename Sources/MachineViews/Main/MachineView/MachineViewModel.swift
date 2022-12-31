//
//  MachineViewModel.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import Foundation
import GUUI
import AttributeViews
import Attributes
import MetaMachines
import Utilities
import GUUI

final class MachineViewModel: ObservableObject, GlobalChangeNotifier {
    
    var machine: MetaMachine {
        get {
            machineRef.machine.value
        } set {
            self.objectWillChange.send()
            machineRef.machine.value = newValue
        }
    }
    
    var canvasViewModel: CanvasViewModel
    
    weak var notifier: GlobalChangeNotifier?
    
    var focus: Focus {
        get {
            focusRef.value
        } set {
            attributesPaneViewModel.objectWillChange.send()
            canvasViewModel.objectWillChange.send()
            self.objectWillChange.send()
            focusRef.value = newValue
        }
    }
    
    lazy var attributesPaneViewModel: AttributesPaneViewModel = {
        AttributesPaneViewModel(machineRef: machineRef.machine, focusRef: focusRef, notifier: notifier)
    }()
    
    var machineRef: Ref<GUIMachine>
    
    var focusRef: Ref<Focus>
    
    convenience init(notifier: GlobalChangeNotifier? = nil) {
        let machineRef = Ref(copying: GUIMachine(machine: MetaMachine.initialSwiftMachine, layout: nil))
        let focusRef = Ref(copying: Focus.machine)
        let canvasViewModel = CanvasViewModel(machineRef: machineRef.machine, focusRef: focusRef)
        self.init(machineRef: machineRef, focusRef: focusRef, canvasViewModel: canvasViewModel, notifier: notifier)
    }
    
    init(machineRef: Ref<GUIMachine>, focusRef: Ref<Focus>, canvasViewModel: CanvasViewModel, notifier: GlobalChangeNotifier? = nil) {
        self.machineRef = machineRef
        self.focusRef = focusRef
        self.canvasViewModel = canvasViewModel
        self.notifier = notifier
        self.canvasViewModel.delegate = self
    }
    
    convenience init(machineRef: Ref<GUIMachine>, notifier: GlobalChangeNotifier? = nil) {
        let focusRef = Ref(copying: Focus.machine)
        let canvasViewModel = CanvasViewModel(machineRef: machineRef.machine, focusRef: focusRef, layout: machineRef.value.layout, notifier: notifier)
        self.init(machineRef: machineRef, focusRef: focusRef, canvasViewModel: canvasViewModel, notifier: notifier)
    }
    
    func send() {
        attributesPaneViewModel.send()
        canvasViewModel.send()
        self.objectWillChange.send()
    }
    
}

extension MachineViewModel: CanvasViewModelDelegate {
    
    func didChangeFocus(_: CanvasViewModel) {
        self.attributesPaneViewModel.objectWillChange.send()
    }
    
    func layoutDidChange(_: CanvasViewModel, layout: Layout) {
        machineRef.value.layout = layout
    }
    
}
