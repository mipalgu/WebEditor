//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 29/4/21.
//

import GUUI
import Attributes
import AttributeViews
import Utilities
import MetaMachines

struct DependenciesAttributesView<Root: Modifiable, Value: DependenciesContainer>: View {
    
    @Binding var root: Root
    
    let path: Attributes.Path<Root, Value>
    
    let label: String
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Form {
                HStack {
                    VStack(alignment: .leading) {
//                        CollectionView(
//                            root: $root,
//                            path: path.dependencyAttributes,
//                            label: label,
//                            type: root[keyPath: path.path].dependencyAttributeType
//                        )
                    }
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 10)
        .tabItem {
            Text("Dependencies")
        }
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
