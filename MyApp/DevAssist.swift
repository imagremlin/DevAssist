import SwiftUI

@main struct DevAssist: App {
    
    @State private var store = ClipStore()
    
    var body: some Scene {
        WindowGroup("Dev Assist") {
            ContentView()
                .environment(store)
        }
    }
}
