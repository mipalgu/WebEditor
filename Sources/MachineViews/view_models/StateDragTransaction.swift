//
//  File.swift
//  
//
//  Created by Morgan McColl on 15/5/21.
//

import TokamakShim
import Machines

struct StateDragTransaction {
    
    private let stateStartPoint: CGPoint
    private let stateTracker: StateTracker
    private let transitionStartPoints: [ObjectIdentifier: Curve]
    private let sourceTrackers: [TransitionTracker]
    private let targetTrackers: [TransitionTracker]
    
    init?(viewModel: CanvasViewModel, stateName: StateName) {
        guard let state = viewModel.machine.states.first(where: { $0.name == stateName }) else {
            return nil
        }
        let stateViewModel = viewModel.viewModel(forState: stateName)
        self.stateTracker = stateViewModel.tracker
        self.stateStartPoint = stateViewModel.tracker.location
        self.transitionStartPoints = Dictionary(uniqueKeysWithValues: viewModel.machine.states.flatMap { state in
            state.transitions.indices.compactMap {
                if !(state.name == stateName || state.transitions[$0].target == stateName) {
                    return nil
                }
                let viewModel = viewModel.viewModel(forTransition: $0, attachedToState: state.name)
                return (viewModel.tracker.id, viewModel.tracker.curve)
            }
        })
        self.sourceTrackers = state.transitions.indices.map {
            stateViewModel.viewModel(forTransition: $0).tracker
        }
        self.targetTrackers = viewModel.machine.states.flatMap { (state) -> [TransitionTracker] in
            let stateViewModel = viewModel.viewModel(forState: state.name)
            return state.transitions.indices.compactMap { (index) -> TransitionTracker? in
                if state.transitions[index].target != stateName {
                    return nil
                }
                return stateViewModel.viewModel(forTransition: index).tracker
            }
        }
    }
    
    func move(by translation: CGSize) {
        stateTracker.location = stateStartPoint.moved(by: translation)
        sourceTrackers.forEach {
            guard let startPoint = transitionStartPoints[$0.id]?.point0 else {
                return
            }
            $0.curve.point0 = startPoint.moved(by: translation)
        }
        targetTrackers.forEach {
            guard let startPoint = transitionStartPoints[$0.id]?.point3 else {
                return
            }
            $0.curve.point3 = startPoint.moved(by: translation)
        }
    }
}
