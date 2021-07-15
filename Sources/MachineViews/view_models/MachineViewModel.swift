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
    
    var machine: MetaMachine
    
    weak var notifier: GlobalChangeNotifier?
    
    var focus: Focus = .machine {
        willSet {
            attributesPaneViewModel.objectWillChange.send()
            canvasViewModel.objectWillChange.send()
        }
    }
    
    lazy var attributesPaneViewModel: AttributesPaneViewModel = {
        AttributesPaneViewModel(machineRef: machineRef, focusRef: focusRef, notifier: notifier)
    }()
    
    lazy var canvasViewModel: CanvasViewModel = {
        let decoder = PropertyListDecoder()
        let plistURL = machine.filePath.appendingPathComponent("Layout.plist")
        let layout: Layout?
        if let data = try? Data(contentsOf: plistURL), let plist = try? decoder.decode(Layout.self, from: data) {
            layout = plist
        } else {
            layout = nil
        }
        return CanvasViewModel(
            machineRef: machineRef,
            focusRef: focusRef,
            layout: layout,
            notifier: notifier
        )
    }()
    
    var machineRef: Ref<MetaMachine> {
        Ref(
            get: { self.machine },
            set: { self.machine = $0 }
        )
    }
    
    var focusRef: Ref<Focus> {
        Ref(
            get: { self.focus },
            set: { self.focus = $0 }
        )
    }
    
    convenience init?(filePath url: URL, notifier: GlobalChangeNotifier? = nil) {
        guard let machine = try? MetaMachine(filePath: url) else {
            return nil
        }
        self.init(machine: machine, notifier: notifier)
    }
    
    init(machine: MetaMachine, notifier: GlobalChangeNotifier? = nil) {
        self.machine = machine
        self.notifier = notifier
    }
    
    func send() {
        attributesPaneViewModel.send()
        canvasViewModel.send()
        self.objectWillChange.send()
    }
    
}
