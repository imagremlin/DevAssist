//
//  TypeService.swift
//  Dev Assist
//
//  Created by Luis on 20/11/2026.
//

import SwiftUI

@Observable
class TypeService {
    
    func type(_ string: String) async {
        try? await Task.sleep(for: .milliseconds(150))
        for char in string {
            if char.isNewline {
                press(36)   // Return
            } else if char == "\t" {
                press(48)   // Tab
            } else {
                type(char)
            }
            try? await Task.sleep(for: .milliseconds(50))
        }
    }
    
    func type(_ char: Character) {
        post(unicode: Array(String(char).utf16))
    }
    
    func press(_ virtualKey: CGKeyCode) {
        post(virtualKey: virtualKey)
    }
 
    private func post(virtualKey: CGKeyCode = 0, unicode: [UInt16]? = nil) {
        for keyDown in [true, false] {
            let event = CGEvent(keyboardEventSource: nil, virtualKey: virtualKey, keyDown: keyDown)
            if let unicode {
                event?.keyboardSetUnicodeString(stringLength: unicode.count, unicodeString: unicode)
            }
            event?.flags = []
            event?.post(tap: .cghidEventTap)
        }
    }
}
