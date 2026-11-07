//
//  ProcessInfoExtensions.swift
//  Dev Assist
//
//  Created by Luis on 7/11/2026.
//

import Foundation

extension ProcessInfo {
    var isRunningTests: Bool {
        environment["XCTestConfigurationFilePath"] != nil
    }
}
