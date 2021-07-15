//
//  File.swift
//  
//
//  Created by Morgan McColl on 25/11/20.
//

import TokamakShim

public struct StringHelper {
    
    public init() {}
    
    public func tab(data: String) -> String {
        let lines = data.split(separator: "\n")
        let tabbedLines = lines.map { "\t" + $0 }
        return reduceLines(data: tabbedLines)
    }
    
    public func reduceLines(data: [String]) -> String {
        data.reduce("") {
            if $0 == "" {
                return $1
            }
            if $1 == "" {
                return $0
            }
            return $0 + "\n" + $1
        }
    }
    
    public func getValueFromFloat(plist data: String, label: String) -> CGFloat {
        guard let val = Double(data.components(separatedBy: "<key>\(label)</key>")[1]
        .components(separatedBy: "<real>")[1].components(separatedBy: "</real>")[0]) else {
            fatalError("Failed to read PList when converting float (data, label): (\(data), \(label))")
        }
        return CGFloat(val)
    }
    
    public func getValueFromBool(plist data: String, label: String) -> Bool {
        let val = data.components(separatedBy: "<key>\(label)</key>")[1]
            .components(separatedBy: "<key>")[0].trimmingCharacters(in: .whitespacesAndNewlines)
        if val == "<true/>" {
            return true
        }
        if val == "<false/>" {
            return false
        }
        fatalError("Failed to convert plist to a bool value (data, label): (\(data), \(label))\n\n\nThe value in question: \(val)")
    }
    
}
