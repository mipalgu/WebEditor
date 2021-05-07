//
//  File.swift
//  
//
//  Created by Morgan McColl on 1/5/21.
//

import Foundation
import TokamakShim
import Machines
import Utilities
import AttributeViews

final class ViewCache {
    
    fileprivate var machineBinding: Binding<Machine>
    
    fileprivate var notifier: GlobalChangeNotifier?
    
    fileprivate var states: [StateName: StateViewModel]
    
    fileprivate var stateTrackers: [StateName: StateTracker]
    
    fileprivate var transitions: [StateName: [TransitionViewModel]]
    
    fileprivate var transitionTrackers: [StateName: [TransitionTracker]]
    
    fileprivate var targetTransitions: [StateName: [StateName: Set<TransitionViewModel>]]
    
    var keys: [StateName] {
        Array(states.keys)
    }
    
    fileprivate var machine: Machine {
        machineBinding.wrappedValue
    }
    
    fileprivate init() {
        machineBinding = .constant(Machine.initialSwiftMachine())
        states = [:]
        stateTrackers = [:]
        transitions = [:]
        transitionTrackers = [:]
        targetTransitions = [:]
    }
    
    private init(machineBinding: Binding<Machine>, states: [StateName: StateViewModel], stateTrackers: [StateName: StateTracker], transitions: [StateName: [TransitionViewModel]], transitionTrackers: [StateName: [TransitionTracker]], targetTransitions: [StateName: [StateName: Set<TransitionViewModel>]], notifier: GlobalChangeNotifier? = nil) {
        self.machineBinding = machineBinding
        self.states = states
        self.stateTrackers = stateTrackers
        self.transitions = transitions
        self.transitionTrackers = transitionTrackers
        self.targetTransitions = targetTransitions
        self.notifier = notifier
        self.states.values.forEach {
            $0.cache = self
        }
    }
    
    convenience init(machine: Binding<Machine>, notifier: GlobalChangeNotifier? = nil) {
        self.init()
        var tempStates: [StateName: StateViewModel] = [:]
        var tempStateTrackers: [StateName: StateTracker] = [:]
        var tempTransitions: [StateName: [TransitionViewModel]] = [:]
        var tempTransitionTrackers: [StateName: [TransitionTracker]] = [:]
        var tempTargetTransitions: [StateName: [StateName: Set<TransitionViewModel>]] = [:]
        machine.wrappedValue.states.indices.forEach { stateIndex in
            let stateName = machine.wrappedValue.states[stateIndex].name
            tempStates[stateName] = StateViewModel(
                machine: machine,
                path: machine.wrappedValue.path.states[stateIndex],
                state: machine.states[stateIndex],
                stateIndex: stateIndex,
                cache: self,
                notifier: notifier
            )
            tempStateTrackers[stateName] = StateTracker(notifier: notifier)
        }
        tempStates.keys.forEach { target in
            tempStates.keys.forEach { source in
                guard let _ = tempTargetTransitions[target] else {
                    var newDict: [StateName: Set<TransitionViewModel>] = [:]
                    newDict[source] = []
                    tempTargetTransitions[target] = newDict
                    return
                }
                tempTargetTransitions[target]![source] = []
            }
        }
        machine.wrappedValue.states.indices.forEach { stateIndex in
            let stateName = machine.wrappedValue.states[stateIndex].name
            var tempTransitionArray: [TransitionViewModel] = []
            var tempTransitionTrackerArray: [TransitionTracker] = []
            machine.wrappedValue.states[stateIndex].transitions.indices.forEach { transitionIndex in
                let transition = machine.wrappedValue.states[stateIndex].transitions[transitionIndex]
                let transitionViewModel = TransitionViewModel(
                    machine: machine,
                    path: machine.wrappedValue.path.states[stateIndex].transitions[transitionIndex],
                    transitionBinding: machine.states[stateIndex].transitions[transitionIndex],
                    stateIndex: stateIndex,
                    transitionIndex: transitionIndex,
                    notifier: notifier
                )
                guard
                    let sourceTracker = tempStateTrackers[stateName],
                    let targetTracker = tempStateTrackers[transition.target]
                else {
                    fatalError("Machine is corrupted.")
                }
                tempTransitionArray.append(transitionViewModel)
                tempTransitionTrackerArray.append(TransitionTracker(source: sourceTracker, target: targetTracker))
                guard let _ = tempTargetTransitions[transition.target] else {
                    var newDict: [StateName: Set<TransitionViewModel>] = [:]
                    newDict[stateName] = [transitionViewModel]
                    tempTargetTransitions[transition.target] = newDict
                    return
                }
                guard let _ = tempTargetTransitions[transition.target]![stateName] else {
                    tempTargetTransitions[transition.target]![stateName] = [transitionViewModel]
                    return
                }
                tempTargetTransitions[transition.target]![stateName]!.insert(transitionViewModel)
            }
            tempTransitions[stateName] = tempTransitionArray
            tempTransitionTrackers[stateName] = tempTransitionTrackerArray
        }
        self.init(
            machineBinding: machine,
            states: tempStates,
            stateTrackers: tempStateTrackers,
            transitions: tempTransitions,
            transitionTrackers: tempTransitionTrackers,
            targetTransitions: tempTargetTransitions,
            notifier: notifier
        )
    }
    
    func addNewState(stateIndex: Int, stateName: StateName, state: Binding<Machines.State>) -> Bool {
        let newViewModel = StateViewModel(
            machine: machineBinding,
            path: machine.path.states[stateIndex],
            state: state,
            stateIndex: stateIndex,
            cache: self,
            notifier: notifier
        )
        createNewTargetEntry(target: stateName)
        self.states[stateName] = newViewModel
        self.stateTrackers[stateName] = StateTracker(notifier: self.notifier)
        self.transitions[stateName] = []
        self.transitionTrackers[stateName] = []
        return true
    }
    
    func addNewTransition(stateIndex: Int, transitionIndex: Int, target: StateName, startLocation: CGPoint, endLocation: CGPoint, transitionBinding: Binding<Transition>) -> Bool {
        let state = machineBinding.wrappedValue.states[stateIndex].name
        guard
            transitions[state] != nil,
            transitions[state]!.count == transitionIndex, //fails here
            let sourceTracker = stateTrackers[state],
            let targetTracker = stateTrackers[target]
        else {
            return false
        }
        let newViewModel = TransitionViewModel(
            machine: machineBinding,
            path: machineBinding.wrappedValue.path.states[stateIndex].transitions[transitionIndex],
            transitionBinding: transitionBinding,
            stateIndex: stateIndex,
            transitionIndex: transitionIndex,
            notifier: notifier
        )
        transitions[state]!.append(newViewModel)
        transitionTrackers[state]!.append(
            TransitionTracker(
                source: sourceTracker,
                sourcePoint: startLocation,
                target: targetTracker,
                targetPoint: endLocation
            )
        )
        targetTransitions[target]![state]!.insert(newViewModel)
        return true
    }
    
    func deleteState(name: StateName) -> Bool {
        states[name] = nil
        stateTrackers[name] = nil
        transitions[name] = nil
        transitionTrackers[name] = nil
        deleteTargetEntries(target: name)
        return true
    }
    
    func deleteStates(names: [StateName]) -> Bool {
        names.forEach {
            if !deleteState(name: $0) {
                fatalError("Couldn't delete state: \($0)")
            }
        }
        return true
    }
    
    func deleteTransition(from source: StateName, at index: Int) -> Bool {
        guard
            let stateIndex = machine.states.firstIndex(where: { $0.name == source }),
            machine.states[stateIndex].transitions.count > index
        else {
            return false
        }
        let transition = machine.states[stateIndex].transitions[index]
        let viewModel = transitions[source]![index]
        targetTransitions[transition.target]![source]!.remove(viewModel)
        transitions[source]!.remove(at: index)
        transitionTrackers[source]!.remove(at: index)
        return true
    }
    
    func finishDrag(for state: Machines.State, gesture: DragGesture.Value, frame: CGSize) {
        finishDrag(for: state.name, gesture: gesture, frame: frame)
    }
    
    func finishDrag(for state: StateName, gesture: DragGesture.Value, frame: CGSize) {
        stateTrackers[state]!.finishDrag(gesture: gesture, frameWidth: frame.width, frameHeight: frame.height)
    }
    
    func handleDrag(for state: Machines.State, gesture: DragGesture.Value, frame: CGSize) {
        handleDrag(for: state.name, gesture: gesture, frame: frame)
    }
    
    func handleDrag(for state: StateName, gesture: DragGesture.Value, frame: CGSize) {
        stateTrackers[state]!.handleDrag(gesture: gesture, frameWidth: frame.width, frameHeight: frame.height)
    }
    
    func overlappingState(point: CGPoint) -> StateName? {
        stateTrackers.keys.first(where: {
            stateTrackers[$0]!.isWithin(point: point)
        })
    }
    
    func renameState(oldName: StateName, newName: StateName) {
        guard nil != states[oldName] else {
            return
        }
        states[newName] = states[oldName]!
        states[oldName] = nil
        stateTrackers[newName] =  stateTrackers[oldName]!
        stateTrackers[oldName] = nil
        transitions[newName] = transitions[oldName]!
        transitions[oldName] = nil
        transitionTrackers[newName] = transitionTrackers[oldName]!
        transitionTrackers[oldName] = nil
        targetTransitions[newName] = targetTransitions[oldName]!
        targetTransitions[oldName] = nil
        targetTransitions.keys.forEach { target in
            guard let targets = targetTransitions[target]?[oldName] else {
                return
            }
            targetTransitions[target]![newName] = targets
            targetTransitions[target]![oldName] = nil
        }
    }
    
    func tracker(for state: Machines.State) -> StateTracker {
        stateTrackers[state.name]!
    }
    
    func tracker(for stateName: StateName) -> StateTracker {
        stateTrackers[stateName]!
    }
    
    func tracker(for transition: Int, originating from: Machines.State) -> TransitionTracker {
        tracker(for: transition, originating: from.name)
    }
    
    func tracker(for transition: Int, originating from: StateName) -> TransitionTracker {
        guard
            nil != transitionTrackers[from],
            transitionTrackers[from]!.count > transition
        else {
            fatalError("Failed to fetch transition tracker.")
        }
        return transitionTrackers[from]![transition]
    }
    
    func trackers(for state: Machines.State) -> [TransitionTracker] {
        trackers(for: state.name)
    }
    
    func trackers(for state: StateName) -> [TransitionTracker] {
        transitionTrackers[state]!
    }
    
    func transition(for source: Machines.State) -> [TransitionViewModel] {
        transitions(source: source.name)
    }
    
    func transition(for target: Machines.State) -> [StateName: Set<TransitionViewModel>] {
        transitions(target: target.name)
    }
    
    func transitions(source: StateName) -> [TransitionViewModel] {
        transitions[source]!
    }
    
    func transitions(target: StateName) -> [StateName: Set<TransitionViewModel>] {
        targetTransitions[target]!
    }
    
    func transitions(for target: Machines.State, from source: Machines.State) -> Set<TransitionViewModel> {
        transitions(for: target.name, from: source.name)
    }
    
    func transitions(for target: StateName, from source: StateName) -> Set<TransitionViewModel> {
        targetTransitions[target]![source]!
    }
    
    func updateTracker(for state: Machines.State, expanded: Bool) -> Bool {
        updateTracker(for: state.name, expanded: expanded)
    }
    
    func updateTracker(for stateName: StateName, expanded: Bool) -> Bool {
        guard let tracker = stateTrackers[stateName] else {
            return false
        }
        guard tracker.expanded != expanded else {
            return true
        }
        return updateTracker(
            for: stateName,
            newTracker: StateTracker(
                location: tracker.location,
                expandedWidth: tracker.expandedWidth,
                expandedHeight: tracker.expandedHeight,
                expanded: expanded,
                collapsedWidth: tracker.collapsedWidth,
                collapsedHeight: tracker.collapsedHeight,
                isText: tracker.isText,
                notifier: self.notifier
            )
        )
    }
    
    func updateTracker(for state: Machines.State, isText: Bool) -> Bool {
        updateTracker(for: state.name, isText: isText)
    }
    
    func updateTracker(for stateName: StateName, isText: Bool) -> Bool {
        guard let tracker = stateTrackers[stateName] else {
            return false
        }
        guard tracker.isText != isText else {
            return true
        }
        return updateTracker(
            for: stateName,
            newTracker: StateTracker(
                location: tracker.location,
                expandedWidth: tracker.expandedWidth,
                expandedHeight: tracker.expandedHeight,
                expanded: tracker.expanded,
                collapsedWidth: tracker.collapsedWidth,
                collapsedHeight: tracker.collapsedHeight,
                isText: isText,
                notifier: self.notifier
            )
        )
    }
    
    func updateTracker(for state: Machines.State, newLocation: CGPoint) -> Bool {
        updateTracker(for: state.name, newLocation: newLocation)
    }
    
    func updateTracker(for stateName: StateName, newLocation: CGPoint) -> Bool {
        guard let tracker = stateTrackers[stateName] else {
            return false
        }
        return updateTracker(
            for: stateName,
            newTracker: StateTracker(
                location: newLocation,
                expandedWidth: tracker.expandedWidth,
                expandedHeight: tracker.expandedHeight,
                expanded: tracker.expanded,
                collapsedWidth: tracker.collapsedWidth,
                collapsedHeight: tracker.collapsedHeight,
                isText: tracker.isText,
                notifier: notifier
            )
        )
    }
    
    func updateTracker(for state: Machines.State, newSize: CGSize) -> Bool {
        updateTracker(for: state.name, newSize: newSize)
    }
    
    func updateTracker(for stateName: StateName, newSize: CGSize) -> Bool {
        guard let tracker = stateTrackers[stateName] else {
            return false
        }
        return updateTracker(
            for: stateName,
            newTracker: StateTracker(
                location: tracker.location,
                expandedWidth: tracker.expanded ? newSize.width : tracker.expandedWidth,
                expandedHeight: tracker.expanded ? newSize.height : tracker.expandedHeight,
                expanded: tracker.expanded,
                collapsedWidth: tracker.expanded ? tracker.collapsedWidth : newSize.width,
                collapsedHeight: tracker.expanded ? tracker.collapsedHeight : newSize.height,
                isText: tracker.isText,
                notifier: notifier
            )
        )
    }
    
    func updateTracker(for state: Machines.State, newTracker: StateTracker) -> Bool {
        updateTracker(for: state.name, newTracker: newTracker)
    }
    
    func updateTracker(for stateName: StateName, newTracker: StateTracker) -> Bool {
        guard let _ = stateTrackers[stateName] else {
            fatalError("Updating tracker that doesn't exist")
        }
        stateTrackers[stateName] = newTracker
        return true
    }
    
    func updateTracker(for transition: Int, in state: Machines.State, curve: Curve) -> Bool {
        updateTracker(for: transition, in: state.name, curve: curve)
    }
    
    func updateTracker(for transition: Int, in state: StateName, curve: Curve) -> Bool {
        updateTracker(
            for: transition,
            in: state,
            newTracker: TransitionTracker(curve: curve)
        )
    }
    
    func updateTracker(for transition: Int, in state: Machines.State, newTracker: TransitionTracker) -> Bool {
        updateTracker(for: transition, in: state.name, newTracker: newTracker)
    }
    
    func updateTracker(for transition: Int, in state: StateName, newTracker: TransitionTracker) -> Bool {
        guard
            let trackers = transitionTrackers[state],
            trackers.count > transition
        else {
            return false
        }
        transitionTrackers[state]![transition] = newTracker
        return true
    }
    
    func updateTracker(for transition: Int, in state: Machines.State, point0: CGPoint) -> Bool {
        updateTracker(for: transition, in: state.name, point0: point0)
    }
    
    func updateTracker(for transition: Int, in state: StateName, point0: CGPoint) -> Bool {
        guard
            let trackers = transitionTrackers[state],
            trackers.count > transition
        else {
            return false
        }
        let tracker = trackers[transition]
        return updateTracker(
            for: transition,
            in: state,
            newTracker: TransitionTracker(
                point0: point0,
                point1: tracker.curve.point1,
                point2: tracker.curve.point2,
                point3: tracker.curve.point3
            )
        )
    }
    
    func updateTracker(for transition: Int, in state: Machines.State, point3: CGPoint) -> Bool {
        updateTracker(for: transition, in: state.name, point3: point3)
    }
    
    func updateTracker(for transition: Int, in state: StateName, point3: CGPoint) -> Bool {
        guard
            let trackers = transitionTrackers[state],
            trackers.count > transition
        else {
            return false
        }
        let tracker = trackers[transition]
        return updateTracker(
            for: transition,
            in: state,
            newTracker: TransitionTracker(
                point0: tracker.curve.point0,
                point1: tracker.curve.point1,
                point2: tracker.curve.point2,
                point3: point3
            )
        )
    }
    
    func viewModel(for state: Machines.State) -> StateViewModel {
        viewModel(for: state.name)
    }
    
    func viewModel(for stateName: StateName) -> StateViewModel {
        states[stateName]!
    }
    
    func viewModel(for transition: Int, originating from: Machines.State) -> TransitionViewModel {
        viewModel(for: transition, originating: from.name)
    }
    
    func viewModel(for transition: Int, originating from: StateName) -> TransitionViewModel {
        guard
            nil != transitions[from],
            transitions[from]!.count > transition
        else {
            fatalError("Failed to fetch transition.")
        }
        return transitions[from]![transition]
    }
    
    func viewModels() -> [StateViewModel] {
        Array(states.values)
    }
    
    fileprivate func createNewTargetEntry(target name: StateName) {
        let names = self.states.keys
        var targetDictionary: [StateName: Set<TransitionViewModel>] = [:]
        names.forEach {
            targetDictionary[$0] = []
        }
        self.targetTransitions[name] = targetDictionary
    }
    
    fileprivate func deleteTargetEntries(target name: StateName) {
        self.targetTransitions[name] = nil
        self.targetTransitions.keys.forEach {
            self.targetTransitions[$0]![name] = nil
        }
    }
    
}

extension ViewCache {
    
    convenience init(machine: Binding<Machine>, plist data: String, notifier: GlobalChangeNotifier? = nil) {
        self.init()
        var tempStates: [StateName: StateViewModel] = [:]
        var tempStateTrackers: [StateName: StateTracker] = [:]
        var tempTransitions: [StateName: [TransitionViewModel]] = [:]
        var tempTransitionTrackers: [StateName: [TransitionTracker]] = [:]
        var tempTargetTransitions: [StateName: [StateName: Set<TransitionViewModel>]] = [:]
        machine.wrappedValue.states.forEach { target in
            machine.wrappedValue.states.forEach { source in
                guard let _ = tempTargetTransitions[target.name] else {
                    var newDict: [StateName: Set<TransitionViewModel>] = [:]
                    newDict[source.name] = []
                    tempTargetTransitions[target.name] = newDict
                    return
                }
                tempTargetTransitions[target.name]![source.name] = []
            }
        }
        // Create models from plist
        machine.wrappedValue.states.indices.forEach { (stateIndex: Int) in
            let stateName = machine.wrappedValue.states[stateIndex].name
            let statePlist: String = data.components(separatedBy: "<key>\(stateName)</key>")[1]
                .components(separatedBy: "<key>zoomedOnExitHeight</key>")[0]
            let transitionsPlist: String = statePlist.components(separatedBy: "<key>Transitions</key>")[1].components(separatedBy: "<key>bgColour</key>")[0]
            let transitionTrackers = machine.wrappedValue.states[stateIndex].transitions.indices.map { (priority: Int) -> TransitionTracker in
                let transitionPlist = transitionsPlist.components(separatedBy: "</dict>")[priority]
                    .components(separatedBy: "<dict>")[1]
                return TransitionTracker(plist: transitionPlist)
            }
            let transitionViewModels = machine.wrappedValue.states[stateIndex].transitions.indices.map { (priority: Int) -> TransitionViewModel in
                let transition = machine.wrappedValue.states[stateIndex].transitions[priority]
                let viewModel = TransitionViewModel(
                    machine: machine,
                    path: machine.wrappedValue.path.states[stateIndex].transitions[priority],
                    transitionBinding: machine.states[stateIndex].transitions[priority],
                    stateIndex: stateIndex,
                    transitionIndex: priority,
                    notifier: notifier
                )
                guard let _ = tempTargetTransitions[transition.target] else {
                    var newDict: [StateName: Set<TransitionViewModel>] = [:]
                    newDict[stateName] = [viewModel]
                    tempTargetTransitions[transition.target] = newDict
                    return viewModel
                }
                guard let _ = tempTargetTransitions[transition.target]![stateName] else {
                    tempTargetTransitions[transition.target]![stateName] = [viewModel]
                    return viewModel
                }
                tempTargetTransitions[transition.target]![stateName]!.insert(viewModel)
                return viewModel
            }
            tempTransitions[stateName] = transitionViewModels
            tempTransitionTrackers[stateName] = transitionTrackers
            tempStateTrackers[stateName] = StateTracker(plist: statePlist, notifier: notifier)
            tempStates[stateName] = StateViewModel(
                machine: machine,
                path: machine.wrappedValue.path.states[stateIndex],
                state: machine.states[stateIndex],
                stateIndex: stateIndex,
                cache: self,
                notifier: notifier
            )
        }
        // Correct for invalid plist transition snap points
        tempTransitions.keys.forEach { state in
            guard let trackers = tempTransitionTrackers[state] else {
                return
            }
            trackers.indices.forEach { trackerIndex in
                guard let stateIndex = machine.wrappedValue.states.firstIndex(where: { $0.name == state }) else {
                    return
                }
                let stateObj = machine.wrappedValue.states[stateIndex]
                guard stateObj.transitions.count > trackerIndex else {
                    return
                }
                let transition = stateObj.transitions[trackerIndex]
                guard
                    let tracker = tempTransitionTrackers[state]?[trackerIndex],
                    tempStates[state] != nil,
                    tempStates[transition.target] != nil,
                    let sourceTracker = tempStateTrackers[state],
                    let targetTracker = tempStateTrackers[transition.target]
                else {
                    return
                }
                guard
                    !tempStateTrackers[transition.target]!.isWithin(point: tracker.curve.point3),
                    tempStateTrackers[transition.target]!.onEdge(point: tracker.curve.point3)
                else {
                    tempTransitionTrackers[state]![trackerIndex] = TransitionTracker(
                        source: sourceTracker,
                        target: targetTracker
                    )
                    return
                }
                
            }
        }
        self.init(
            machineBinding: machine,
            states: tempStates,
            stateTrackers: tempStateTrackers,
            transitions: tempTransitions,
            transitionTrackers: tempTransitionTrackers,
            targetTransitions: tempTargetTransitions,
            notifier: notifier
        )
    }
    
    var plist: String {
        let helper = StringHelper()
        let statesPlist = helper.reduceLines(data: machine.states.sorted(by: { $0.name < $1.name }).map { state in
            guard let stateTracker = stateTrackers[state.name] else {
                return ""
            }
            let transitions = self.trackers(for: state)
            return stateTracker.plist(state: state, transitions: transitions)
        })
        return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
        "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" +
            "<plist version=\"1.0\">\n<dict>\n" + helper.tab(
                data: "<key>States</key>\n<dict>\n" + helper.tab(data: statesPlist) + "\n</dict>\n<key>Version</key>\n<string>1.3</string>"
            ) +
        "\n</dict>\n</plist>\n"
    }
    
}
