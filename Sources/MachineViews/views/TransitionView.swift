//
//  TransitionView.swift
//  
//
//  Created by Morgan McColl on 16/11/20.
//

import TokamakShim

import Machines
import Attributes
import Utilities
import AttributeViews

struct TransitionLabelView: View {
    
    @ObservedObject var viewModel: TransitionViewModel
    
    var body: some View {
        Text(viewModel.condition)
    }
    
}

struct TransitionEditLabelView: View {
    
    @ObservedObject var viewModel: TransitionViewModel
    
    var body: some View {
        LineView<Config>(root: $viewModel.machine, path: viewModel.path.condition, label: "Condition")
    }
    
}

struct TransitionView<Label: View, EditLabel: View>: View {
    
    @ObservedObject var viewModel: TransitionTracker
    
    var focused: Bool
    
    let label: () -> Label
    
    let editLabel: () -> EditLabel
    
    @EnvironmentObject var config: Config
    
    init(viewModel: TransitionTracker, focused: Bool = false, label: @escaping () -> Label, editLabel: @escaping () -> EditLabel) {
        self.viewModel = viewModel
        self.focused = focused
        self.label = label
        self.editLabel = editLabel
    }
    
    var body: some View {
        ZStack {
            ArrowWithLabelView(
                curve: $viewModel.curve,
                strokeNumber: 0,
                editing: focused,
                color: focused ? config.highlightColour : config.textColor,
                label: label,
                editLabel: editLabel
            )
            if focused {
                AnchorPoint(width: 20, height: 20)
                    .position(viewModel.curve.point0)
                    .gesture(DragGesture().onChanged {
                        viewModel.curve.point0 = $0.location
                    }.onEnded {
                        viewModel.curve.point0 = $0.location
                    })
                AnchorPoint(color: .red)
                    .position(viewModel.curve.point1)
                    .gesture(DragGesture().onChanged {
                        viewModel.curve.point1 = $0.location
                    }.onEnded {
                        viewModel.curve.point1 = $0.location
                    })
                AnchorPoint(color: .blue)
                    .position(viewModel.curve.point2)
                    .gesture(DragGesture().onChanged {
                        viewModel.curve.point2 = $0.location
                    }.onEnded {
                        viewModel.curve.point2 = $0.location
                    })
                AnchorPoint(width: 20, height: 20)
                    .position(viewModel.curve.point3)
                    .gesture(DragGesture().onChanged {
                        viewModel.curve.point3 = $0.location
                    }.onEnded {
                        viewModel.curve.point3 = $0.location
                    })
            }
        }
    }
}

//struct TransitionView_Previews: PreviewProvider {
//    
//    struct Focused_Preview: View {
//        
//        @State var point0: CGPoint = CGPoint(x: 50, y: 50)
//        @State var point1: CGPoint = CGPoint(x: 100, y: 100)
//        @State var point2: CGPoint = CGPoint(x: 150, y: 100)
//        @State var point3: CGPoint = CGPoint(x: 150, y: 50)
//        @State var strokeNumber: UInt8 = 2
//        @State var label: String = "true"
//        @State var focused: Bool = true
//        
//        let config = Config()
//        
//        var body: some View {
//            TransitionView(
//                machine: Machi
//                point0: $point0,
//                point1: $point1,
//                point2: $point2,
//                point3: $point3,
//                strokeNumber: strokeNumber,
//                focused: $focused
//            ).environmentObject(config)
//        }
//        
//    }
//    
//    struct Unfocused_Preview: View {
//        
//        @State var point0: CGPoint = CGPoint(x: 50, y: 50)
//        @State var point1: CGPoint = CGPoint(x: 100, y: 100)
//        @State var point2: CGPoint = CGPoint(x: 150, y: 100)
//        @State var point3: CGPoint = CGPoint(x: 150, y: 50)
//        @State var strokeNumber: UInt8 = 2
//        @State var label: String = "true"
//        @State var focused: Bool = false
//        
//        let config = Config()
//        
//        var body: some View {
//            TransitionView(
//                point0: $point0,
//                point1: $point1,
//                point2: $point2,
//                point3: $point3,
//                strokeNumber: $strokeNumber,
//                label: $label,
//                focused: $focused
//            ).environmentObject(config)
//        }
//        
//    }
//    
//    static var previews: some View {
//        VStack {
//            Focused_Preview()
//            Unfocused_Preview()
//        }
//    }
//}
