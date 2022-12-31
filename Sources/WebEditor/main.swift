import MetaMachines
import Attributes

#if canImport(TokamakShim)
import GUUI
typealias State = TokamakShim.State
#else
import SwiftUI
typealias State = SwiftUI.State
#endif

import MachineViews
import Utilities
import GUUI

enum WindowType {
    case undecided
    case machine(machine: GUIMachine)
    
    var machine: GUIMachine {
        get {
            switch self {
            case .machine(let machine):
                return machine
            default:
                fatalError("Not a machine")
            }
        }
        set {
            switch self {
            case .machine:
                self = .machine(machine: newValue)
            default:
                fatalError("Not a machine")
            }
        }
    }
}

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
        DocumentGroup(newDocument: { MachineDocument(type: .undecided) }) { file in
            WindowView(viewModel: WindowViewModel(ref: file.document.ref))
        }
    }
}

import UniformTypeIdentifiers

final class MachineDocument: ReferenceFileDocument {
    
    static var readableContentTypes: [UTType] = [.machine, .directory]
    
    var ref: Ref<WindowType>
    
    init(ref: Ref<WindowType>) {
        self.ref = ref
    }
    
    convenience init(metaMachine: MetaMachine) {
        self.init(type: WindowType.machine(machine: GUIMachine(machine: metaMachine, layout: nil)))
    }
    
    convenience init(type: WindowType) {
        self.init(ref: Ref(copying: type))
    }
    
    convenience init(configuration: ReadConfiguration) throws {
        let machine = try GUIMachine(from: configuration.file)
        self.init(type: .machine(machine: machine))
    }
    
    func snapshot(contentType: UTType) throws -> WindowType {
        ref.value
    }
    
    func fileWrapper(snapshot: WindowType, configuration: FileDocumentWriteConfiguration) throws -> FileWrapper {
        switch snapshot {
        case .machine(let machine):
            return try machine.fileWrapper()
        default:
            throw AttributeError(message: "Trying to get fileWrapper for something that isn't a machine", path: MetaMachine.path)
        }
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

final class WindowViewModel: ObservableObject {
    
    var ref: Ref<WindowType>
    
    var type: WindowType {
        get {
            ref.value
        }
        set {
            ref.value = newValue
            objectWillChange.send()
        }
    }
    
    init(ref: Ref<WindowType>) {
        self.ref = ref
    }
    
}

struct WindowView: View {
    
    @StateObject var viewModel: WindowViewModel
    
    init(viewModel: WindowViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        switch viewModel.type {
        case .machine:
            MainView(machineRef: viewModel.ref.machine)
        default:
            VStack {
                ForEach(0..<MetaMachine.supportedSemantics.count) { index in
                    Button(action: {
                        viewModel.type = .machine(machine: GUIMachine(machine: MetaMachine.initialMachine(forSemantics: MetaMachine.supportedSemantics[index]), layout: nil))
                    }) {
                        Text(MetaMachine.supportedSemantics[index].rawValue)
                    }
                }
            }
        }
    }
    
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
WebEditor.main()
