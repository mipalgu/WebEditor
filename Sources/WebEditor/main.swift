import MetaMachines
import Attributes

#if canImport(TokamakShim)
import TokamakShim
typealias State = TokamakShim.State
#else
import SwiftUI
typealias State = SwiftUI.State
#endif

import MachineViews
import Utilities
import GUUI

struct WebEditor: App {
    
    #if canImport(SwiftUI)
    class AppDelegate: NSObject, NSApplicationDelegate {
        
//        func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
//            return true
//        }
//
        func applicationWillFinishLaunching(_ notification: Notification) {
            NSApp.setActivationPolicy(.regular)
            if let image = APP_ICON {
                NSApp.applicationIconImage = image
            }
        }
        
    }
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    #endif
    
    var body: some Scene {
        DocumentGroup(newDocument: { MachineDocument(metaMachine: MetaMachine.initialSwiftMachine) }) { file in
            MainView(machineRef: file.document.machineRef)
        }
    }
}

import UniformTypeIdentifiers

final class MachineDocument: ReferenceFileDocument {
    
    static var readableContentTypes: [UTType] = [.machine, .directory]
    
    var machineRef: Ref<GUIMachine>
    
    init(machineRef: Ref<GUIMachine>) {
        self.machineRef = machineRef
    }
    
    convenience init(metaMachine: MetaMachine) {
        self.init(machine: GUIMachine(machine: metaMachine, layout: nil))
    }
    
    convenience init(machine: GUIMachine) {
        self.init(machineRef: Ref(copying: machine))
    }
    
    convenience init(configuration: ReadConfiguration) throws {
        let machine = try GUIMachine(from: configuration.file)
        self.init(machine: machine)
    }
    
    func snapshot(contentType: UTType) throws -> GUIMachine {
        machineRef.value
    }
    
    func fileWrapper(snapshot: GUIMachine, configuration: WriteConfiguration) throws -> FileWrapper {
        let wrapper = try snapshot.fileWrapper()
        return wrapper
    }
    
}

extension UTType {
    
    static var arrangement: UTType {
        UTType(filenameExtension: "arrangement")!
    }
    
    static var micaseMachine: UTType {
        UTType(importedAs: "net.mipal.micase.fsm")
    }
    
    static var machine: UTType {
        UTType(filenameExtension: "machine")!
    }
    
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
WebEditor.main()
