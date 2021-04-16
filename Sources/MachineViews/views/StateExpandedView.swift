//
//  StateExpandedView.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities
import AttributeViews

struct StateExpandedView<TitleView: View>: View {
    
    @Binding var state: Machines.State
    @Binding var collapsedActions: [String: Bool]
    let titleView: () -> TitleView
    let codeView: (Int) -> CodeViewWithDropDown<Text>
    
    init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Machines.State>, collapsedActions: Binding<[String: Bool]>, titleView: @escaping () -> TitleView) {
        self.init(
            state: Binding(
                get: { root.wrappedValue[keyPath: path.keyPath] },
                set: {
                    _ = try? root.wrappedValue.modify(attribute: path, value: $0)
                }
            ),
            collapsedActions: collapsedActions,
            titleView: titleView,
            codeView: {
                let name = root.wrappedValue[keyPath: path.keyPath].actions[$0].name
                return CodeViewWithDropDown(
                    root: root,
                    path: path.actions[$0].implementation,
                    label: name,
                    language: root.wrappedValue[keyPath: path.keyPath].actions[$0].language,
                    collapsed: Binding(
                        get: {
                            collapsedActions.wrappedValue[name] ?? false
                        },
                        set: {
                            collapsedActions.wrappedValue[name] = $0
                        }
                    )
                )
            }
        )
    }
    
    init(state: Binding<Machines.State>, collapsedActions: Binding<[String: Bool]>, actionErrors: Binding<[[String]]> = .constant([]), titleView: @escaping () -> TitleView) {
        self.init(
            state: state,
            collapsedActions: collapsedActions,
            titleView: titleView,
            codeView: {
                let name = state.wrappedValue.actions[$0].name
                return CodeViewWithDropDown(
                    value: state.actions[$0].implementation,
                    errors: actionErrors[$0],
                    label: name,
                    language: state.actions[$0].language.wrappedValue,
                    collapsed: Binding(
                        get: {
                            collapsedActions.wrappedValue[name] ?? false
                        },
                        set: {
                            collapsedActions.wrappedValue[name] = $0
                        }
                    )
                )
            }
        )
    }
    
    private init(state: Binding<Machines.State>, collapsedActions: Binding<[String: Bool]>, titleView: @escaping () -> TitleView, codeView: @escaping (Int) -> CodeViewWithDropDown<Text>) {
        self._state = state
        self._collapsedActions = collapsedActions
        self.titleView = titleView
        self.codeView = codeView
    }
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        GeometryReader{ reader in
            VStack {
                titleView()
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(state.actions.indices, id: \.self) { index in
                            codeView(index)
                        }
                    }
                }
//                RoundedRectangle(cornerRadius: 20.0)
//                    .strokeBorder(Color.black, lineWidth: 3.0, antialiased: true)
//                    .background(RoundedRectangle(cornerRadius: 20.0).foregroundColor(config.stateColour))
//                    .clipped()
//                    .shadow(color: config.shadowColour, radius: 10, x: 0, y: 10)
//                    .overlay (
//                        VStack {
//                            HStack {
//                                titleView()
//                                    .multilineTextAlignment(.center)
//                                    .font(config.fontTitle2)
//                                    .background(config.fieldColor)
//    //                                .padding(.leading, viewModel.buttonDimensions)
//    //                                .frame(
//    //                                    minWidth: viewModel.minTitleWidth - viewModel.buttonDimensions,
//    //                                    maxWidth: viewModel.maxTitleWidth - viewModel.buttonDimensions,
//    //                                    minHeight: viewModel.minTitleHeight,
//    //                                    maxHeight: viewModel.maxTitleHeight
//    //                                )
//                                    .clipped()
//    //                            Button(action: { viewModel.toggleExpand(frameWidth: reader.size.width, frameHeight: reader.size.height, externalTransitions: editorViewModel.machine.getExternalTransitionsForState(state: viewModel)) }) {
//    //                                Image(systemName: "arrowtriangle.down.fill")
//    //                                    .font(.system(size: viewModel.buttonSize, weight: .regular))
//    //                                    .frame(width: viewModel.buttonDimensions, height: viewModel.buttonDimensions)
//    //                            }.buttonStyle(PlainButtonStyle())
//                            }
//
//                        }
//                        .padding(.bottom, 20)
//                        .padding(.top, 10)
//                        .frame(minHeight: 50)
//    //                    .background(
//    //                        RoundedRectangle(cornerRadius: 20.0)
//    //                        .strokeBorder(borderColor, lineWidth: 3.0, antialiased: true)
//    //                        .frame(width: width - 10.0, height: height - 10.0)
//    //                        .opacity(viewModel.isAccepting ? 1.0 : 0.0)
//    //                    )
//                    )
            }//.strokeBorder(Color.black, lineWidth: 3.0, antialiased: true)
        }.clipShape(RoundedRectangle(cornerRadius: 20.0))
        .background(config.stateColour)
    }
}

struct StateExpandedView_Previews: PreviewProvider {
    
//    struct Root_Preview: View {
//
//        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
//            AttributeGroup(
//                name: "Fields", fields: [Field(name: "float", type: .float)], attributes: ["float": .float(0.1)], metaData: [:])
//        ])
//
//        let path = EmptyModifiable.path.attributes[0].attributes["float"].wrappedValue.floatValue
//
//        let config = DefaultAttributeViewsConfig()
//
//        var body: some View {
//            FloatView<DefaultAttributeViewsConfig>(
//                root: $modifiable,
//                path: path,
//                label: "Root"
//            ).environmentObject(config)
//        }
//
//    }
    
    struct Binding_Preview: View {
        
        @State var value: Machines.State = Machines.State(
            name: "Initial",
            actions: [
                Action(name: "OnEntry", implementation: "let a = 2", language: .swift),
                Action(name: "OnExit", implementation: "let b = 3", language: .swift),
                Action(name: "Main", implementation: "let c = 4", language: .swift),
                Action(name: "OnSuspend", implementation: "let d = 5", language: .swift),
                Action(name: "OnResume", implementation: "let e = 6", language: .swift)
            ],
            transitions: []
        )
        
        @State var titleErrors: [String] = ["An error", "A second error"]
        
        @State var actionErrors: [[String]] = Array(repeating: [], count: 5)
        
        @State var collapsedActions: [String: Bool] = [:]
        
        let config = Config()
        
        var body: some View {
            StateExpandedView<LineView<Config>>(
                state: $value,
                collapsedActions: $collapsedActions,
                actionErrors: $actionErrors
            ) {
                LineView<Config>(value: $value.name, errors: $titleErrors, label: "State Name")
            }.environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            //Root_Preview()
            Binding_Preview()
        }
    }
}
