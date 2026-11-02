//
//  ClipboardService.swift
//  Dev Assist
//
//  Created by Luis on 2/11/2026.
//

import SwiftUI

@MainActor
@Observable
class ClipboardService {
    
    private let pb = NSPasteboard.general
    private(set) var lastCleared: Date?
    @ObservationIgnored private var clearClipboardTask: Task<Void, Never>?
    
    func readText() -> String? {
        pb.string(forType: .string)
    }
    
    func copy(_ text: String, concealed: Bool = false) {
        pb.clearContents()
        pb.setString(text, forType: .string)
        clearClipboardTask?.cancel()
        if concealed {
            pb.setData(Data(), forType: .concealed)
            let count = pb.changeCount
            clearClipboardTask = Task {
                do {
                    try await Task.sleep(for: .seconds(30))
                    
                    if count == pb.changeCount {
                        pb.clearContents()
                        lastCleared = .now
                    }
                } catch  { }
            }
        }
    }
}
