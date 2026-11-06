//
//  AppWindow.swift
//  Dev Assist
//
//  Created by Luis on 7/11/2026.
//

enum AppWindow: String {
    case main, clipProperties, logProcessor

    var id: String {
        switch self {
        case .main:             "main"
        case .clipProperties:   "clipProperties"
        case .logProcessor:     "logProcessor"
        }
    }
    
    var title: String {
        switch self {
        case .main:             "Dev Assist"
        case .clipProperties:   "Clip Properties"
        case .logProcessor:     "Log Processor"
        }
    }
    
}
