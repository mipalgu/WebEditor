//
//  File.swift
//  
//
//  Created by Morgan McColl on 6/5/21.
//

import Foundation
import TokamakShim
import MetaMachines
import AttributeViews
import Attributes
import Utilities
import GUUI

final class ArrangementViewModel: ObservableObject, GlobalChangeNotifier {
    
    weak var notifier: GlobalChangeNotifier?
    
    var arrangement: Arrangement
    
    lazy var attributeGroupsViewModel: AttributeGroupsViewModel<Arrangement> = {
        AttributeGroupsViewModel(rootRef: rootRef, path: Arrangement.path.attributes, notifier: notifier)
    }()
    
    private var rootRef: Ref<Arrangement> {
        Ref(
            get: { self.arrangement },
            set: { self.arrangement = $0 }
        )
    }
    
    init(arrangement: Arrangement, notifier: GlobalChangeNotifier? = nil) {
        self.arrangement = arrangement
        self.notifier = notifier
    }
    
    func send() {
        attributeGroupsViewModel.send()
        objectWillChange.send()
    }
    
}
