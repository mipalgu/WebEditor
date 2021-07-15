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
        WindowGroup("Web Editor") {
            WebEditorWindow(display: .none)
        }.commands(content: {
            AppCommands()
        })
    }
}

struct AppCommands: Commands {
    
    @FocusedBinding(\.saving) var saving: Bool?
    
    @FocusedBinding(\.cutting) var cutting: Bool?
    
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("Save") {
                saving?.toggle()
            }.keyboardShortcut(KeyEquivalent("s"), modifiers: .command).disabled(saving == nil)
        }
        CommandGroup(replacing: .pasteboard) {
            Button("Cut") {
                cutting?.toggle()
            }.keyboardShortcut("x", modifiers: .command).disabled(cutting == nil)
            Button("Copy") {
                print("I'm copying")
            }.keyboardShortcut("c", modifiers: .command)
            Button("Paste") {
                print("I'm pasting")
            }.keyboardShortcut("v", modifiers: .command)
            Button("Delete") {
                print("I'm deleting")
            }.keyboardShortcut(.delete)
            Button("Select All") {
                print("I'm selecting all")
            }.keyboardShortcut("a", modifiers: .command)
        }
    }
    
}

enum DisplayType {
    
    case arrangement(Arrangement)
    case machine(MetaMachine)
    case none
    
}

struct WebEditorWindow: View {
    
    @State var display: DisplayType
    
    var config: Config = Config()
    
    var body: some View {
        switch display {
        case .arrangement(let arrangement):
            MainView(arrangement: arrangement).environmentObject(config)
        case .machine(let machine):
            MainView(machine: machine).environmentObject(config)
        case .none:
            WebEditorDefaultMenu(display: $display)
        }
    }
    
}

import UniformTypeIdentifiers

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

struct DirectoryFileDocument: FileDocument {
    
    static var readableContentTypes: [UTType] = [.directory, .arrangement, .micaseMachine, .machine]
    
    static var arrangementReadableContentTypes: [UTType] = [.directory, .arrangement]
    
    static var machineReadableContentTypes: [UTType] = [.directory, .micaseMachine, .machine]
    
    init() {}

    init(configuration: ReadConfiguration) throws {}

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(directoryWithFileWrappers: [:])
    }

}

struct WebEditorDefaultMenu: View {
    
    enum FileType: Equatable {
        
        var isArrangement: Bool {
            switch self {
            case .arrangement:
                return true
            default:
                return false
            }
        }
        
        var isMachine: Bool {
            switch self {
            case .machine:
                return true
            default:
                return false
            }
        }
        
        case arrangement(Arrangement.Semantics)
        case machine(MetaMachine.Semantics)
    }
    
    enum Sheets {
        case new
        case open
    }
    
    @Binding var display: DisplayType
    
    @State var presentNewFileSheet: Bool = false
    
    @State var presentOpenFileSheet: Bool = false
    
    @State var fileType: FileType
    
    init(display: Binding<DisplayType>, showing: Sheets? = nil, fileType: FileType = .arrangement(.swiftfsm)) {
        self._display = display
        self._fileType = State(initialValue: fileType)
        guard let showing = showing else {
            return
        }
        switch showing {
        case .new:
            presentNewFileSheet = true
        case .open:
            presentOpenFileSheet = true
        }
    }
    
    var body: some View {
        VStack {
            ForEach(Arrangement.supportedSemantics, id: \.self) { semantics in
                Button("New \(semantics.rawValue) Arrangement") {
                    fileType = .arrangement(semantics)
                    presentNewFileSheet = true
                }
            }
            ForEach(MetaMachine.supportedSemantics, id: \.self) { semantics in
                Button("New \(semantics.rawValue) Machine") {
                    fileType = .machine(semantics)
                    presentNewFileSheet = true
                }
            }
            ForEach(Arrangement.supportedSemantics, id: \.self) { semantics in
                Button("Open \(semantics.rawValue) Arrangement") {
                    fileType = .arrangement(semantics)
                    presentOpenFileSheet = true
                }
            }
            ForEach(MetaMachine.supportedSemantics, id: \.self) { semantics in
                Button("Open \(semantics.rawValue) Machine") {
                    fileType = .machine(semantics)
                    presentOpenFileSheet = true
                }
            }
        }
        .frame(minWidth: 500, minHeight: 300)
        .fileExporter(
            isPresented: $presentNewFileSheet,
            document: DirectoryFileDocument(),
            contentType: fileType.isArrangement ? UTType.arrangement : UTType.machine,
            onCompletion: {
                defer { presentNewFileSheet = false }
                switch $0 {
                case .failure(let error):
                    print("\(error)")
                    return
                case .success(let url):
                    switch fileType {
                    case .arrangement(let semantics):
                        let arrangement = Arrangement.initialArrangement(forSemantics: semantics, filePath: url)
                        do {
                            try arrangement.save()
                        } catch let e {
                            print("\(e)")
                            return
                        }
                        display = .arrangement(arrangement)
                    case .machine(let semantics):
                        let machine = MetaMachine.initialMachine(forSemantics: semantics, filePath: url)
                        do {
                            try machine.save()
                        } catch let e {
                            print("\(e)")
                        }
                        display = .machine(machine)
                    }
                    
                }
            }
        )
        .fileImporter(
            isPresented: $presentOpenFileSheet,
            allowedContentTypes: fileType.isArrangement ? DirectoryFileDocument.arrangementReadableContentTypes : DirectoryFileDocument.machineReadableContentTypes,
            allowsMultipleSelection: false
        ) {
            defer { presentOpenFileSheet = false }
            switch $0 {
            case .failure(let error):
                print("\(error)")
                return
            case .success(let urls):
                guard let url = urls.first else {
                    return
                }
                switch fileType {
                case .arrangement:
                    let arrangement: Arrangement
                    do {
                        arrangement = try Arrangement(loadAtFilePath: url)
                    } catch let e {
                        print("\(e)")
                        return
                    }
                    display = .arrangement(arrangement)
                case .machine:
                    let machine: MetaMachine
                    do {
                        machine = try MetaMachine(filePath: url)
                    } catch let e {
                        print("\(e)")
                        return
                    }
                    display = .machine(machine)
                }
            }
        }
    }
    
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
WebEditor.main()
