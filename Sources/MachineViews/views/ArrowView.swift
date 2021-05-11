//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 2/12/20.
//

import TokamakShim

import Utilities

struct ArrowView<StrokeView: View>: View {
    
    @Binding var curve: Curve
    
    var colour: Color
    
    let strokeView: (Binding<Curve>) -> StrokeView
    
    var arrowPoint0: CGPoint {
        let theta = atan2(Double(curve.point3.y - curve.point2.y), Double(curve.point3.x - curve.point2.x)) +  Double.pi - Double.pi / 6.0
        let y = curve.point3.y + CGFloat(10.0 * sin(theta))
        let x = curve.point3.x + CGFloat(10.0 * cos(theta))
        return CGPoint(x: x, y: y)
    }
    
    var arrowPoint1: CGPoint {
        let theta = atan2(Double(curve.point3.y - curve.point2.y), Double(curve.point3.x - curve.point2.x)) + Double.pi + Double.pi / 6.0
        let y = curve.point3.y + CGFloat(10.0 * sin(theta))
        let x = curve.point3.x + CGFloat(10.0 * cos(theta))
        return CGPoint(x: x, y: y)
    }
    
    @EnvironmentObject public var config: Config
    
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: curve.point0)
                path.addCurve(to: curve.point3, control1: curve.point1, control2: curve.point2)
                path.move(to: curve.point3)
                path.addLine(to: arrowPoint0)
                path.move(to: curve.point3)
                path.addLine(to: arrowPoint1)
            }
            .stroke(colour, lineWidth: 2)
            //.coordinateSpace(name: "MAIN_VIEW")
            .foregroundColor(config.textColor)
            strokeView($curve)
        }
    }
}

//struct ArrowView_Previews: PreviewProvider {
//    
//    struct Preview: View {
//        
//        @State var curve = Curve(
//            point0: CGPoint(x: 50, y: 50),
//            point1: CGPoint(x: 100, y: 100),
//            point2: CGPoint(x: 150, y: 100),
//            point3: CGPoint(x: 150, y: 50)
//        )
//        
//        let strokeNumber: UInt8 = 2
//        let color: Color = .black
//        
//        let config = Config()
//        
//        var body: some View {
//            ArrowView(
//                curve: $curve,
//                strokeNumber: strokeNumber,
//                colour: color
//            ).environmentObject(config)
//        }
//        
//    }
//    
//    static var previews: some View {
//        VStack {
//            Preview()
//        }
//    }
//}
