import SwiftUI

struct ContentView: View {
    
    @Environment(ClipStore.self) private var store
    @Environment(ClipboardService.self) private var clipboardService
    
    @State private var selection: Clip.ID?
    @State private var editingClip: Clip?
    @State private var toast: Toast?
    @State private var toastTask: Task<Void, Never>?
    @State private var searchText = ""
    @State private var confirmingClear = false
    
    private var selectedClip: Clip? {
        selection.flatMap { store[$0] }
    }
    
    private var filteredClips: [Clip] {
        guard !searchText.isEmpty else { return store.displayClips }
        return store.displayClips.filter { $0.matches(searchText) }
    }
    
    private func show(_ toast: Toast) {
        withAnimation { self.toast = toast }
        toastTask?.cancel()
        toastTask = Task {
            do {
                try await Task.sleep(for: .seconds(1.5))
                withAnimation { self.toast = nil }
            } catch { }
        }
    }
    
    private func copy(_ clip: Clip) {
        clipboardService.copy(clip.text, concealed: clip.isSensitive)
        store.markUsed(clip)
        show(.copied)
    }
    
    var body: some View {
        
        VStack(spacing : 0) {
            searchBar
            Divider()
            clipList
            Divider()
            bottomBar
            
        }.onChange(of: clipboardService.lastCleared) {
            show(.cleared)
        }.overlay(RoundedRectangle(cornerRadius: 4).stroke(.separator))
            .padding()
            .frame(minWidth: 250, minHeight: 250)
            .overlay {
                if let toast {
                    VStack {
                        Image(systemName: toast.symbol)
                            .font(.system(size: 40))
                        Text(toast.caption)
                    }.padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                        .transition(.opacity)
                }
            }
    }
    
    private var searchBar: some View {
        HStack(spacing: 4) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
            }
        }
        .padding(6)
    }
    
    private var clipList: some View {
        List(filteredClips, selection: $selection) { clip in
            HStack {
                Text(clip.displayText)
                    .italic(!clip.title.isEmpty)
                    .help(clip.tooltip)
                Spacer()
                if clip.isSensitive {
                    Image(systemName: "eye.slash")
                        .foregroundStyle(.secondary)
                    
                }
                if clip.isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.secondary)
                    
                }
            }
        }.sheet(item: $editingClip) { clip in
            PropertiesView(clip: clip) { updated in
                store.addOrUpdate(updated)
            }
        }.listStyle(.plain)
            .contextMenu(forSelectionType: Clip.ID.self) { ids in
                if let id = ids.first, var clip = store[id] {
                    Button("Copy") {
                        copy(clip)
                    }
                    Button("Update") {
                        if let text = clipboardService.readText() {
                            clip.text = text
                            store.addOrUpdate(clip)
                            show(.updated)
                        }
                    }
                    
                    Button(clip.isLocked ? "Unlock" : "Lock") {
                        store.toggleLock(clip.id)
                    }
                    
                    Button(clip.isSensitive ? "Clear Sensitive" : "Make Sensitive") {
                        clip.isSensitive = !clip.isSensitive
                        store.addOrUpdate(clip)
                    }
                    
                    Button("Remove") {
                        store.remove(clip.id)
                    }.disabled(clip.isLocked)
                    
                    Button("Get information…") {
                        editingClip = clip
                    }
                }
            } primaryAction: { ids in
                if let id = ids.first, let clip = store[id] {
                    copy(clip)
                }
            }.onDeleteCommand {
                if let selection, let clip = store[selection], !clip.isLocked {
                    store.remove(clip.id)
                    self.selection = nil
                }
            }
    }
    
    private var bottomBar: some View {
        HStack(spacing: 0) {
            Button {
                if let text = clipboardService.readText(), let clip = ClipStore.makeClip(text)  {
                    if NSEvent.modifierFlags.contains(.option) {
                        editingClip = clip
                    } else {
                        store.addOrUpdate(clip)
                    }
                }
            } label: {
                Image(systemName: "plus")
                    .frame(width: 24, height: 22)
                    .contentShape(Rectangle())
            }.buttonStyle(.borderless)
                .keyboardShortcut("v", modifiers: .command)
                .help("Add from clipboard. (⌥-click to add with title)")
            Button {
                if let selection {
                    store.remove(selection)
                }
                selection = nil
            } label: {
                Image(systemName: "minus")
                    .frame(width: 24, height: 22)
                    .contentShape(Rectangle())
            }.buttonStyle(.borderless)
                .disabled(selectedClip?.isLocked ?? true)
                .help("Remove selected")
            
            Button {
                editingClip = selectedClip
            } label: {
                Image(systemName: "info")
                    .frame(width: 24, height: 22)
                    .contentShape(Rectangle())
            }.buttonStyle(.borderless)
                .disabled(selectedClip == nil)
                .help("Get information")
            Button {
                store.removeAll()
                show(.cleared)
                selection = nil
            } label: {
                Image(systemName: "trash")
                    .frame(width: 24, height: 22)
                    .contentShape(Rectangle())
            }.buttonStyle(.borderless)
                .disabled(store.clips.isEmpty)
                .help("Clear unlocked")
            Spacer()
        }.frame(height: 24)
    }
}

extension NSPasteboard.PasteboardType {
    static let concealed = Self("org.nspasteboard.ConcealedType")
}


