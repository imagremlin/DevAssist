//
//  PropertiesView.swift
//  Dev Assist
//
//  Created by Luis on 31/10/2026.
//

import SwiftUI

struct PropertiesView: View {

    @State private var draft: Clip
    @Environment(\.dismiss) private var dismiss
    let onSave: (Clip) -> Void

    init(clip: Clip, onSave: @escaping (Clip) -> Void) {
        _draft = State(initialValue: clip)
        self.onSave = onSave
    }
    
    var body: some View {
        Form {
            Toggle("Locked", isOn: $draft.isLocked)
            Toggle("Masked", isOn: $draft.isMasked)
            TextField("Mask", text: $draft.mask)
        }.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave(draft)
                    dismiss()
                }.disabled(draft.isMasked && draft.mask.isEmpty)
            }
        }.padding()
    }
}

