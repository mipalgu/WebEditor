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
            TabView(selection: Binding($viewModel.selection)) {
                ForEach(viewModel.attributes.indices, id: \.self) { index in
                    AttributeGroupView<Config>(root: $viewModel.root, path: viewModel.path[index], label: viewModel.attribute(at: index).name, notifier: viewModel.notifier)
                        .padding(.horizontal, 10)
                        .tabItem {
                            Text(viewModel.attribute(at: index).name.pretty)
                        }
                }
                if let extraTabs = extraTabs {
                    extraTabs()
                }
            }
        }
    }
}
