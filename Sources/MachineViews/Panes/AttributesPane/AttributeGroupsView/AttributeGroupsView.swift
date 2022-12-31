//
//  AttributeGroupsView.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

import GUUI

import MetaMachines
import Attributes
import Utilities
import AttributeViews
import GUUI

public struct AttributeGroupsView<Root: Modifiable, ExtraTabs: View>: View {
    
    @ObservedObject var viewModel: AttributeGroupsViewModel<Root>
    
    let label: String
    let extraTabs: (() -> ExtraTabs)?
    
    @EnvironmentObject var config: Config
    
    init(viewModel: AttributeGroupsViewModel<Root>, label: String, extraTabs: @escaping () -> ExtraTabs) {
        self.viewModel = viewModel
        self.label = label
        self.extraTabs = .some(extraTabs)
    }
    
    init(viewModel: AttributeGroupsViewModel<Root>, label: String) where ExtraTabs == EmptyView {
        self.viewModel = viewModel
        self.label = label
        self.extraTabs = nil
    }
    
    public var body: some View {
        VStack {
            Text(label.pretty)
                .font(.title3)
                .foregroundColor(config.textColor)
            if !viewModel.attributes.isEmpty {
                TabView(selection: Binding($viewModel.selection)) {
                    ForEach(viewModel.attributes, id: \.id) { group in
                        AttributeGroupView(viewModel: group)
                            .padding(.horizontal, 10)
                            .tabItem {
                                Text(group.name.pretty)
                            }
                    }
                    if let extraTabs = extraTabs {
                        extraTabs()
                    }
                }
            } else {
                Spacer()
            }
        }
    }
}
