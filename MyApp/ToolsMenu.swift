//
//  ToolsMenu.swift
//  Dev Assist
//
//  Created by Luis on 7/11/2026.
//

import SwiftUI

struct ToolsMenu: View {
    
    @Environment(\.openWindow) private var openWindow
    @Environment(ClipboardService.self) private var clipboardService
    @AppStorage("autotype") private var autotype = false
    
    var body: some View {
        Button("Log Processor…") {
            openWindow.bringToFront(.logProcessor)
        }
        Button("Remove Formatting") {
            clipboardService.removeFormatting()
        }
        Toggle("Autotype", isOn: $autotype)
    }
}
