//
//  MachineViewModel.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import Foundation
import TokamakShim
import AttributeViews
import Attributes
import MetaMachines
import Utilities
import GUUI

final class MachineViewModel: ObservableObject, GlobalChangeNotifier {
    
    var machine: MetaMachine {
        get {
            machineRef.value
        } set {
            self.objectWillChange.send()
            machineRef.value = newValue
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
        AttributesPaneViewModel(machineRef: machineRef, focusRef: focusRef, notifier: notifier)
    }()
    
    var machineRef: Ref<MetaMachine>
    
    var focusRef: Ref<Focus>
    
    convenience init(notifier: GlobalChangeNotifier? = nil) {
        let machineRef = Ref(copying: MetaMachine.initialSwiftMachine)
        let focusRef = Ref(copying: Focus.machine)
        let canvasViewModel = CanvasViewModel(machineRef: machineRef, focusRef: focusRef)
        self.init(machineRef: machineRef, focusRef: focusRef, canvasViewModel: canvasViewModel, notifier: notifier)
    }
    
    convenience init(filePath url: URL, notifier: GlobalChangeNotifier? = nil) throws {
        let wrapper = try FileWrapper(url: url, options: .immediate)
        try self.init(wrapper: wrapper, notifier: notifier)
    }
    
    init(machineRef: Ref<MetaMachine>, focusRef: Ref<Focus>, canvasViewModel: CanvasViewModel, notifier: GlobalChangeNotifier? = nil) {
        self.machineRef = machineRef
        self.focusRef = focusRef
        self.canvasViewModel = canvasViewModel
        self.notifier = notifier
    }
    
    convenience init(machineRef: Ref<GUIMachine>, notifier: GlobalChangeNotifier? = nil) {
        let focusRef = Ref(copying: Focus.machine)
        let canvasViewModel = CanvasViewModel(machineRef: machineRef.machine, focusRef: focusRef, layout: machineRef.value.layout, notifier: notifier)
        self.init(machineRef: machineRef.machine, focusRef: focusRef, canvasViewModel: canvasViewModel, notifier: notifier)
    }
    
    convenience init(wrapper: FileWrapper, notifier: GlobalChangeNotifier? = nil) throws {
        let machine = try MetaMachine(from: wrapper)
        let decoder = PropertyListDecoder()
        let layout: Layout?
        if let data = wrapper.fileWrappers?["Layout.plist"]?.regularFileContents, let plist = try? decoder.decode(Layout.self, from: data) {
            layout = plist
        } else {
            layout = nil
        }
        let machineRef = Ref(copying: machine)
        let focusRef = Ref(copying: Focus.machine)
        let canvasViewModel = CanvasViewModel(
            machineRef: machineRef,
            focusRef: focusRef,
            layout: layout,
            notifier: notifier
        )
        self.init(machineRef: machineRef, focusRef: focusRef, canvasViewModel: canvasViewModel, notifier: notifier)
    }
    
    func send() {
        attributesPaneViewModel.send()
        canvasViewModel.send()
        self.objectWillChange.send()
    }
    
}
