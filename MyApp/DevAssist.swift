import SwiftUI

@main struct DevAssist: App {
    
    @State private var store = ClipStore()
    @State private var clipboardService = ClipboardService()
    
    var body: some Scene {
        Window(AppWindow.main.title, id: AppWindow.main.id) {
            ContentView()
                .environment(store)
                .environment(clipboardService)
        }.commands {
            CommandMenu("Tools") {
                ToolsMenu()
            }
        }.windowResizability(.contentMinSize)
        
        MenuBarExtra(AppWindow.main.title, systemImage: "doc.on.clipboard") {
            MenuBarView()
                .environment(store)
                .environment(clipboardService)
        }
        
        Window(AppWindow.logProcessor.title, id: AppWindow.logProcessor.id) {
            LogProcessorView()
                .environment(clipboardService)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        
        WindowGroup(AppWindow.clipProperties.title, id: AppWindow.clipProperties.id, for: Clip.ID.self) { $clipID in
            if let clipID, let clip = store[clipID] ?? store.pendingClip(clipID) {
                PropertiesView(clip: clip) {
                    store.addOrUpdate($0)
                }.onDisappear {
                    store.discardPending(clipID)
                }
            } else {
                Text("Clip not found")
                    .padding()
            }
        }.windowResizability(.contentSize)
            .defaultPosition(.center)
    }
}


