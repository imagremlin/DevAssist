import SwiftUI

struct ContentView: View {
    
    @Environment(ClipStore.self) private var store
    
    @State private var selection: Clip.ID?
    @State private var editingClip: Clip?
    @State private var toast: Toast?
    @State private var toastTask: Task<Void, Never>?
    
    private let clipboardService = ClipboardService()
    
    private var selectedClip: Clip? {
        selection.flatMap { store[$0] }
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
        clipboardService.copy(clip.text, concealed: clip.isMasked)
        show(.copied)
    }
    
    var body: some View {
        
        VStack(spacing : 0) {
            List(store.displayClips, selection: $selection) { clip in
                HStack {
                    Text(clip.isMasked ? clip.mask : clip.firstLine).help(clip.isMasked ? "" : clip.text)
                    Spacer()
                    if clip.isMasked {
                        Image(systemName: "eye.slash")
                    }
                    if clip.isLocked {
                        Image(systemName: "lock.fill")
                    }
                }
                
            }.sheet(item: $editingClip) { clip in
                PropertiesView(clip: clip) { updated in
                    store.update(updated)
                }
            }.listStyle(.plain)
                .contextMenu(forSelectionType: Clip.ID.self) { ids in
                    if let id = ids.first, let clip = store[id] {
                        Button("Copy") {
                            copy(clip)
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
                }
            Divider()
            HStack(spacing: 0) {
                
                Button {
                    if let text = clipboardService.readText() {
                        store.add(text)
                    }
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 24, height: 22)
                        .contentShape(Rectangle())
                }.buttonStyle(.borderless)
                    .keyboardShortcut("v", modifiers: .command)
                    .help("Add from clipboard")
                
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
                    .help("Remove current")
                
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
                    selection = nil
                } label: {
                    Image(systemName: "trash")
                        .frame(width: 24, height: 22)
                        .contentShape(Rectangle())
                }.buttonStyle(.borderless)
                    .disabled(store.clips.isEmpty)
                    .help("Clear non locked")
                
                Spacer()
                
            }.frame(height: 24)
            
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
            }.onChange(of: clipboardService.lastCleared) {
                show(.cleared)
            }
    }
}

extension NSPasteboard.PasteboardType {
    static let concealed = Self("org.nspasteboard.ConcealedType")
}
