//
//  File.swift
//  
//
//  Created by Morgan McColl on 6/5/21.
//

import Foundation
import TokamakShim
import Machines

final class ArrangementViewModel: ObservableObject {
    
    var arrangement: Arrangement
    
    init(arrangement: Arrangement) {
        self.arrangement = arrangement
    }
    
}
