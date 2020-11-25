//
//  File.swift
//  
//
//  Created by Morgan McColl on 25/11/20.
//

struct StringHelper {
    
    
    
    func tab(data: String) -> String {
        let lines = data.split(separator: "\n")
        let tabbedLines = lines.map { "\t" + $0 }
        return tabbedLines.reduce("") {
            if $0 == "" {
                return $1
            }
            if $1 == "" {
                return $0
            }
            return $0 + $1
        }
    }
    
}
