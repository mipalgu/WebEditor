import Machines
import Attributes

#if canImport(TokamakDOM)
import TokamakDOM
typealias State = TokamakDOM.State
#else
import SwiftUI
typealias State = SwiftUI.State
#endif

import MachineViews
import Utilities

struct WebEditor: App {
    
    #if !canImport(TokamakDOM) && canImport(SwiftUI)
    class AppDelegate: NSObject, NSApplicationDelegate {
        
//        func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
//            return true
//        }
//
        func applicationWillFinishLaunching(_ notification: Notification) {
            NSApp.setActivationPolicy(.regular)
        }
        
    }
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    #endif
    
    var body: some Scene {
        WindowGroup("Web Editor") {
            WebEditorWindow(display: .none)
        }.commands(content: {
            CommandGroup(replacing: .pasteboard) {
                Button("Cut") {
                    print("I'm cutting")
                }.keyboardShortcut("x", modifiers: .command)
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
        })
    }
}

enum DisplayType {
    
    case arrangement(Arrangement)
    case machine(Machine)
    case none
    
}

struct WebEditorWindow: View {
    
    @State var display: DisplayType
    
    var config: Config = Config()
    
    var body: some View {
        switch display {
        case .arrangement(let arrangement):
            WebEditorArrangementView(viewModel: ArrangementViewModel(arrangement: Ref(copying: arrangement)))
                .environmentObject(config)
        case .machine(let machine):
            WebEditorMachineView(viewModel: MachineViewModel(machine: Ref(copying: machine)))
                .environmentObject(config)
        case .none:
            WebEditorDefaultMenu(display: $display)
        }
    }
    
}

struct WebEditorArrangementView: View {
    
    @StateObject var viewModel: ArrangementViewModel
    
    @EnvironmentObject var config: Config
    
    @State var showArrangement: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            MenuView(
                machineViewModel: Binding<MachineViewModel?>(
                    get: { viewModel.isEmpty ? nil : viewModel.currentMachine.machine },
                    set: { _ in }
                )
            ).background(config.stateColour)
            if !showArrangement && !viewModel.isEmpty {
                TabView(selection: Binding(get: { viewModel.currentMachineIndex }, set: { viewModel.currentMachineIndex = $0 })) {
                    ForEach(Array(viewModel.rootMachineViewModels.indices), id: \.self) { index in
                        ContentView(editorViewModel: viewModel.rootMachineViewModels[index], arrangement: viewModel)
                            .tabItem {
                                Text(viewModel.rootMachineViewModels[index].machine.name)
                                    .font(config.fontHeading)
                            }.tag(index)
                    }
                }.background(config.backgroundColor)
            } else {
                ArrangementView(viewModel: viewModel, showArrangement: $showArrangement)
                    .onTapGesture(count: 2) {
                        viewModel.addRootMachine(semantics: .swiftfsm)
                    }
            }
        }.background(config.backgroundColor)
    }
    
}

struct WebEditorMachineView: View {
    
    @StateObject var viewModel: MachineViewModel
    
    @EnvironmentObject var config: Config

    @State var tabs: [MachineDependency]
    
    @State var selection: Int = 0
    
    init(viewModel: MachineViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._tabs = State(initialValue: [MachineDependency(name: viewModel.machine.name, filePath: viewModel.machine.filePath)])
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            MenuView(machineViewModel: Binding<MachineViewModel?>(get: { viewModel }, set: { _ in })).background(config.stateColour)
//            TabView(selection: $selection) {
//                ForEach(tabs, id: \.self) { dep in
//                    ContentView(editorViewModel: EditorViewModel(machine: MachineViewModel(machine: Ref(copying: Machine(filePath: dep.filePath)))), arrangement: viewModel)
//                        .tabItem {
//                            Text(viewModel.rootMachineViewModels[index].machine.name)
//                                .font(config.fontHeading)
//                        }.tag(index)
//                }
//            }.background(config.backgroundColor)
        }.background(config.backgroundColor)
    }
    
}

import UniformTypeIdentifiers

extension UTType {
    
    static var machine: UTType {
        return UTType(importedAs: "net.mipal.micase.fsm")
    }
    
}

struct DirectoryFileDocument: FileDocument {
    
    static var readableContentTypes: [UTType] = [.directory, .machine]
    
    init() {}

    init(configuration: ReadConfiguration) throws {}

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(directoryWithFileWrappers: [:])
    }

}

struct WebEditorDefaultMenu: View {
    
    enum FileType {
        case arrangement
        case machine(Machine.Semantics)
    }
    
    enum Sheets {
        case new
        case open
    }
    
    @Binding var display: DisplayType
    
    @State var presentNewFileSheet: Bool = false
    
    @State var presentOpenFileSheet: Bool = false
    
    @State var fileType: FileType
    
    init(display: Binding<DisplayType>, showing: Sheets? = nil, fileType: FileType = .arrangement) {
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
            Button("New Arrangement") {
                fileType = .arrangement
                presentNewFileSheet = true
            }
            ForEach(Machine.supportedSemantics, id: \.self) { semantics in
                Button("New \(semantics.rawValue) Machine") {
                    fileType = .machine(semantics)
                    presentNewFileSheet = true
                }
            }
            Button("Open Arrangement") {
                fileType = .arrangement
                presentOpenFileSheet = true
            }
            ForEach(Machine.supportedSemantics, id: \.self) { semantics in
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
            contentType: .directory,
            onCompletion: {
                defer { presentNewFileSheet = false }
                switch $0 {
                case .failure(let error):
                    print("\(error)")
                    return
                case .success(let url):
                    switch fileType {
                    case .arrangement:
                        let arrangement = Arrangement(filePath: url, rootMachines: [])
                        do {
                            try arrangement.save()
                        } catch let e {
                            print("\(e)")
                            return
                        }
                        display = .arrangement(arrangement)
                    case .machine(let semantics):
                        let machine = Machine.initialMachine(forSemantics: semantics)
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
        .fileImporter(isPresented: $presentOpenFileSheet, allowedContentTypes: [.directory, .machine], allowsMultipleSelection: false) {
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
                case .machine(let semantics):
                    let machine: Machine
                    do {
                        machine = try Machine(filePath: url)
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

struct ContentView: View {

//    #if canImport(TokamakDOM)
//    @TokamakShim.State var machine = Machine.initialSwiftMachine
//    #else
//    @SwiftUI.State var machine = Machine.initialSwiftMachine
//    #endif
    
    @EnvironmentObject var config: Config
    /*
    @ObservedObject var machineRef: Ref<Machine>*/
    
    @StateObject var editorViewModel: EditorViewModel
    
    @ObservedObject var arrangement: ArrangementViewModel
    
    var body: some View {
        EditorView(arrangement: arrangement, viewModel: editorViewModel, machineViewModel: editorViewModel.currentMachine)
            .background(config.backgroundColor)
            .frame(minWidth: CGFloat(config.width), minHeight: CGFloat(config.height))
            .onTapGesture(count: 1) {
                let mainView = editorViewModel.mainView
                switch mainView {
                case .machine:
                    editorViewModel.currentMachine.removeHighlights()
                    editorViewModel.changeFocus()
                case .state(let stateIndex):
                    editorViewModel.changeFocus(stateIndex: stateIndex)
                default:
                    return
                }
            }
    }
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
WebEditor.main()
