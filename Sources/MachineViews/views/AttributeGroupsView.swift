//
//  AttributeGroupsView.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

import TokamakShim

import Machines
import Attributes
import Utilities
import AttributeViews
import GUUI

public struct AttributeGroupsView<Root: Modifiable, ExtraTabs: View>: View {
    
    class Temp {
        
        var idCache = IDCache<AttributeGroup>()
        
    }
    
    @Binding var root: Root
    let path: Attributes.Path<Root, [AttributeGroup]>
    let label: String
    let notifier: GlobalChangeNotifier?
    let extraTabs: (() -> ExtraTabs)?
    
    let temp = Temp()
    
    @EnvironmentObject var config: Config
    
    @Binding var selection: Int?
    
    public init(root: Binding<Root>, path: Attributes.Path<Root, [AttributeGroup]>, label: String, selection: Binding<Int?>, notifier: GlobalChangeNotifier? = nil) where ExtraTabs == EmptyView {
        self.init(root: root, path: path, label: label, selection: selection, notifier: notifier, extraTabs: nil)
    }
    
    public init(root: Binding<Root>, path: Attributes.Path<Root, [AttributeGroup]>, label: String, selection: Binding<Int?>, notifier: GlobalChangeNotifier? = nil, extraTabs: (() -> ExtraTabs)?) {
        self._root = root
        self.path = path
        self.label = label
        self._selection = selection
        self.notifier = notifier
        self.extraTabs = extraTabs
    }
    
    var groups: [Row<AttributeGroup>] {
        root[keyPath: path.path].enumerated().map {
            Row(id: temp.idCache.id(for: $1), index: $0, data: $1)
        }
    }
    
    public var body: some View {
        VStack {
            Text(label.capitalized)
                .font(.title3)
                .foregroundColor(config.textColor)
            TabView(selection: Binding($selection)) {
                ForEach(groups.indices, id: \.self) { index in
                    AttributeGroupView<Config>(root: $root, path: path[index], label: root[keyPath: path.keyPath][index].name, notifier: notifier)
                        .padding(.horizontal, 10)
                        .tabItem {
                            Text(root[keyPath: path.keyPath][index].name.pretty)
                        }
                }
                if let extraTabs = extraTabs {
                    extraTabs()
                }
            }
        }
    }
}
