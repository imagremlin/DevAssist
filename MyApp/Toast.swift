//
//  Toast.swift
//  Dev Assist
//
//  Created by Luis on 1/11/2026.
//

import Foundation

enum Toast {
    case copied, cleared, updated, processed
    
    var symbol: String {
        switch self {
            case .copied:  "doc.on.clipboard"
            case .cleared: "eraser.fill"
            case .updated: "square.and.pencil"
            case .processed: "gearshape.2"
        }
    }
    
    var caption: String {
        switch self {
            case .copied:  "Copied"
            case .cleared: "Cleared"
            case .updated: "Updated"
            case .processed: "Processed"
        }
    }
    
}
