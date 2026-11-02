import SwiftUI

@main struct DevAssist: App {
    
    @State private var store = ClipStore()
    @State private var clipboardService = ClipboardService()
    
    var body: some Scene {
        Window("Dev Assist", id: "main") {
            ContentView()
                .environment(store)
                .environment(clipboardService)
        }.windowResizability(.contentMinSize)
        
        MenuBarExtra("Dev Assist", systemImage: "doc.on.clipboard") {
            MenuBarView()
                .environment(store)
                .environment(clipboardService)
        }

    }
}


