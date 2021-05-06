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

final class ArrangementViewModel: ObservableObject {
    
    var arrangement: Arrangement
    
    weak var notifier: GlobalChangeNotifier?
    
    @Published var selection: Int?
    
    init(arrangement: Arrangement, notifier: GlobalChangeNotifier? = nil) {
        self.arrangement = arrangement
        self.notifier = notifier
    }
    
}
