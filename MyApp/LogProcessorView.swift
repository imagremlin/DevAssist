//
//  LogProcessorView.swift
//  Dev Assist
//
//  Created by Luis on 4/11/2026.
//

import SwiftUI

struct LogProcessorView: View {
    
    @AppStorage("logPrefix") private var prefix = ""
    @Environment(ClipboardService.self) private var clipboardService
    @Environment(\.dismiss) private var dismiss
    @FocusState private var prefixFocused: Bool
    
    var body: some View {
        VStack {
            Form {
                TextField("Prefix", text: $prefix)
                    .focused($prefixFocused)
            }
            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }.keyboardShortcut(.cancelAction)
                Button("Process") {
                    if let log = clipboardService.readText() {
                        clipboardService.copy(LogProcessor.clean(log, prefix: prefix))
                    }
                    dismiss()
                }.keyboardShortcut(.defaultAction)
                .disabled(prefix.isEmpty)
            }
        }.onAppear { prefixFocused = true }
        .padding()
        .frame(width: 320)
    }
}
