//
//  OpenWindowActionExtensions.swift
//  Dev Assist
//
//  Created by Luis on 7/11/2026.
//

import SwiftUI

extension OpenWindowAction {
    func bringToFront(_ appWindow: AppWindow) {
        self(id: appWindow.id)
        raise(appWindow)
    }

    func bringToFront<V: Codable & Hashable>(_ appWindow: AppWindow, value: V) {
        self(id: appWindow.id, value: value)
        raise(appWindow)
    }

    private func raise(_ appWindow: AppWindow) {
        NSApp.activate()
        if let window = NSApp.windows.first(where: { $0.title == appWindow.title }) {
            window.orderFrontRegardless()
            window.makeKey()
        }
    }
}
