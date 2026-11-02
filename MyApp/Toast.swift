//
//  Toast.swift
//  Dev Assist
//
//  Created by Luis on 1/11/2026.
//

import Foundation

enum Toast {
    case copied, cleared
    
    var symbol: String {
        switch self {
            case .copied:  "doc.on.clipboard"
            case .cleared: "eraser.fill"
        }
    }
    
    var caption: String {
        switch self {
            case .copied:  "Copied"
            case .cleared: "Cleared"
        }
    }
}
