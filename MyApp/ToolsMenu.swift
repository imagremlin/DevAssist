//
//  ToolsMenu.swift
//  Dev Assist
//
//  Created by Luis on 7/11/2026.
//

import SwiftUI

struct ToolsMenu: View {
    
    @Environment(\.openWindow) private var openWindow
        
    var body: some View {
        Button("Log Processor…") {
            openWindow.bringToFront(.logProcessor)
        }
    }
}
