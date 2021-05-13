//
//  File.swift
//  
//
//  Created by Morgan McColl on 6/5/21.
//

import Foundation
import TokamakShim
import Machines
import AttributeViews
import Attributes
import Utilities

final class ArrangementViewModel: ObservableObject, GlobalChangeNotifier {
    
    weak var notifier: GlobalChangeNotifier?
    
    var arrangement: Arrangement
    
    @Published var selection: ObjectIdentifier?
    
    lazy var attributeGroupsViewModel: AttributeGroupsViewModel<Arrangement> = {
        AttributeGroupsViewModel(rootRef: rootRef, pathRef: ConstRef(get: { Arrangement.path.attributes }), selectionRef: selectionRef, notifier: notifier)
    }()
    
    private var rootRef: Ref<Arrangement> {
        Ref(
            get: { self.arrangement },
            set: { self.arrangement = $0 }
        )
    }
    
    private var selectionRef: Ref<ObjectIdentifier?> {
        Ref(
            get: { self.selection },
            set: { self.selection = $0 }
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
