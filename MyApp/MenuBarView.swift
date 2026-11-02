//
//  MenuBarView.swift
//  Dev Assist
//
//  Created by Luis on 3/11/2026.
//

import SwiftUI

struct MenuBarView: View {
    @Environment(ClipStore.self) private var store
    @Environment(ClipboardService.self) private var clipboardService
    @Environment(\.openWindow) private var openWindow

       var body: some View {
           ForEach (store.recentClips) { clip in
               Button(clip.menuTitle) {
                   clipboardService.copy(clip.text, concealed: clip.isSensitive)
               }
           }
           Divider()
           Button("Add") {
               if let text = clipboardService.readText() {
                   store.add(text)
               }
           }
           Button("Clear All") {
               store.removeAll()
           }
           Divider()
           Button("Open Dev Assist") {
               openWindow(id: "main")
               NSApp.activate()
               NSApp.windows
                   .first { $0.title == "Dev Assist" }?
                   .makeKeyAndOrderFront(nil)
               if let window = NSApp.windows.first(where: { $0.title == "Dev Assist" }) {
                   window.orderFrontRegardless()
                   window.makeKey()
               }
           }
           Button("Quit") {
               NSApp.terminate(nil)
           }.keyboardShortcut("q")
       }
}

