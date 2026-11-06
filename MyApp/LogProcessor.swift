//
//  LogProcessor.swift
//  Dev Assist
//
//  Created by Luis on 4/11/2026.
//

import Foundation

enum LogProcessor  {
    
    static func clean(_ log: String, prefix: String) -> String {
        guard !prefix.isEmpty else { return "" }

        return log.components(separatedBy: .newlines)
            .flatMap { line in
                line.components(separatedBy: prefix)
                    .dropFirst()
                    .map { (prefix + $0).trimmingCharacters(in: .whitespaces) }
            }
            .joined(separator: "\n")
    }
}

