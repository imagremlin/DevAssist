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
        VStack {
            Form {
                Toggle("Locked", isOn: $draft.isLocked)
                Toggle("Sensitive", isOn: $draft.isSensitive)
                TextField("Title", text: $draft.title)
            }
            Divider()
            HStack{
                Spacer()
                Button("Cancel") {
                    dismiss()
                }.keyboardShortcut(.cancelAction)
                Button("Save") {
                    onSave(draft)
                    dismiss()
                }.keyboardShortcut(.defaultAction)
                .disabled(draft.isSensitive && draft.title.isEmpty)
            }
        }.padding()
    }
}

