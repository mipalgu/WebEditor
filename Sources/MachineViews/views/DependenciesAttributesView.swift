//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 29/4/21.
//

import TokamakShim
import Attributes
import AttributeViews
import Utilities
import Machines

struct DependenciesAttributesView<Root: Modifiable, Value: DependenciesContainer>: View {
    
    @Binding var root: Root
    
    let path: Attributes.Path<Root, Value>
    
    var attributes: Attributes.Path<Root, [Attribute]> {
        path.dependencyAttributes
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Form {
                HStack {
                    VStack(alignment: .leading) {
                        CollectionView<Config>(
                            root: $root,
                            path: attributes,
                            label: "",
                            type: root[keyPath: path.path].dependencyAttributeType
                        )
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
