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
    @Environment(TypeService.self) private var typeService
    @Environment(\.openWindow) private var openWindow
    @AppStorage("autotype") private var autotype = false
    
    func use(_ clip: Clip) {
        if autotype || clip.autotypeAlways {
            typeService.type(clip.text)
        } else {
            clipboardService.copy(clip.text, concealed: clip.isSensitive)
        }
        store.markUsed(clip)
    }
    
    var body: some View {
        ForEach(store.recentClips) { clip in
            Button(clip.menuTitle) {
                use(clip)
            }.modifierKeyAlternate(.option, {Button((autotype || clip.autotypeAlways ? "Copy: " : "") + clip.menuTitle) {
                clipboardService.copy(clip.text, concealed: clip.isSensitive)
                store.markUsed(clip)
            }})
        }
        Divider()
        Button("Add from Clipboard") {
            if let text = clipboardService.readText(), let clip = ClipStore.makeClip(text) {
                store.addOrUpdate(clip)
            }
        }.modifierKeyAlternate(.option, {Button("Add with Title…") {
            if let text = clipboardService.readText(),let clip = ClipStore.makeClip(text) {
                store.addPending(clip)
                openWindow.bringToFront(.clipProperties, value: clip.id)
            }
        }})
        
        Button("Clear Unlocked") {
            store.removeAll()
        }
        Divider()
        Button("Log Processor…") {
            openWindow.bringToFront(.logProcessor)
        }
        Button("Remove Formatting") {
            clipboardService.removeFormatting()
        }
        Toggle("Autotype", isOn: $autotype)
        Divider()
        Button("Open Dev Assist") {
            openWindow.bringToFront(.main)
        }
        Button("Quit") {
            NSApp.terminate(nil)
        }.keyboardShortcut("q")
    }
}


