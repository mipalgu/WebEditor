//
//  File.swift
//  File
//
//  Created by Morgan McColl on 8/9/21.
//

import XCTest
import Foundation
import MetaMachines
import GUUI
@testable import MachineViews

final class StateViewModelTests: XCTestCase {
    
    var viewModel: StateViewModel?
    var stateName: String?
    var targetName: String?
    
    public override func setUp() {
        var machine = MetaMachine.initialSwiftMachine
        stateName = machine.states[0].name
        targetName = machine.states[1].name
        let _ = machine.newTransition(source: machine.states[0].name, target: machine.states[1].name, condition: "true")
        let _ = machine.newTransition(source: machine.states[0].name, target: machine.states[1].name, condition: "false")
        let _ = machine.newTransition(source: machine.states[0].name, target: machine.states[1].name, condition: "x == 5")
        viewModel = StateViewModel(machine: Ref(copying: machine), index: 0)
        super.setUp()
    }
    
    
    func testDeleteTransitions() {
        let secondTransition = viewModel?.viewModel(forTransition: 1)
        let thirdTransition = viewModel?.viewModel(forTransition: 2)
        viewModel?.deleteTransitions(in: IndexSet(integer: 0))
        XCTAssertIdentical(secondTransition, viewModel?.viewModel(forTransition: 0))
        XCTAssertIdentical(thirdTransition, viewModel?.viewModel(forTransition: 1))
    }
    
    func testDeleteTransition() {
        let secondTransition = viewModel?.viewModel(forTransition: 1)
        let thirdTransition = viewModel?.viewModel(forTransition: 2)
        viewModel?.deleteTransition(0)
        XCTAssertIdentical(secondTransition, viewModel?.viewModel(forTransition: 0))
        XCTAssertIdentical(thirdTransition, viewModel?.viewModel(forTransition: 1))
    }
    
    static var allTests = [
        ("testDeleteTransitions", testDeleteTransitions),
        ("testDeleteTransition", testDeleteTransition)
    ]
    
}
