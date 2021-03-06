////
////  SwiftUIView.swift
////
////
////  Created by Morgan McColl on 23/11/20.
////
//
//import TokamakShim
//
//import MetaMachines
//import Attributes
//import Utilities
//
//struct DependenciesView: View {
//    
//    let root: Root
//    
//    @ObservedObject var viewModel: DependenciesViewModel
//    
//    @Binding var focus: URL
//    
//    @EnvironmentObject var config: Config
//    
//    let padding: CGFloat = 10
//    
//    init(root: Root, viewModel: DependenciesViewModel, focus: Binding<URL>) {
//        self.root = root
//        self.viewModel = viewModel
//        self._focus = focus
//    }
//    
//    var body: some View {
//        SideBar(collapsed: $viewModel.sideBarCollapsed, width: $viewModel.dependenciesWidth, maxWidth: 600) {
//            VStack {
//                VStack {
//                    HStack {
//                        Toggle(isOn: $viewModel.expanded) {
//                            Text(root.name.pretty)
//                        }
//                        .toggleStyle(ArrowToggleStyle(side: .left))
//                        .onTapGesture {
//                            focus = root.filePath
//                        }
//                        Spacer()
//                    }.padding(.leading, padding)
//                }.background(focus == root.filePath ? AnyView(config.highlightColour.clipShape(RoundedRectangle(cornerRadius: 5))) : AnyView(Color.clear))
//                if viewModel.expanded {
//                    VStack {
//                        ForEach(root.dependencies, id: \.filePath) { dependency in
//                            DependencyView(
//                                dependency: dependency,
//                                viewModel: viewModel.viewModel(forDependency: dependency),
//                                focus: $focus,
//                                padding: padding + padding,
//                                parents: [root.filePath]
//                            )
//                        }
//                    }.padding(.leading, padding)
//                }
//                Spacer()
//            }
//        }.toolbar {
//            ToolbarItem(placement: ToolbarItemPlacement.navigation) {
//                HoverButton(action: {
//                    viewModel.sideBarCollapsed.toggle()
//                }, label: {
//                    Image(systemName: "sidebar.leading").font(.system(size: 16, weight: .regular))
//                })
//            }
//        }
//    }
//    
//}
//
////struct Dependencies_Previews: PreviewProvider {
////
////    struct Preview: View {
////
////        @State var focus: URL = Machine.initialSwiftMachine().filePath
////
////        @State var name: String = "Initial Swift Machine"
////
////        @State var url: URL = Machine.initialSwiftMachine().filePath
////
////        @State var dependencies: [MachineDependency] = Machine.initialSwiftMachine().dependencies
////
////        @State var machines: [URL: MetaMachine] = [:]
////
////        let config = Config()
////
////        var body: some View {
////            DependenciesView(
////                focus: $focus,
////                name: $name,
////                url: $url,
////                dependencies: $dependencies,
////                machines: $machines,
////                width: .constant(200)
////            ).environmentObject(config)
////        }
////
////    }
////
////    static var previews: some View {
////        VStack {
////            Preview()
////        }
////    }
////}
