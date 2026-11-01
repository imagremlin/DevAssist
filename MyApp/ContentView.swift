import SwiftUI

struct ContentView: View {
    
    @State private var store = ClipStore()
    @State private var selection: Clip.ID?
    @State private var editingClip: Clip?
    @State private var clearClipboardTask: Task<Void, Never>?
    @State private var toast: Toast?
    @State private var toastTask: Task<Void, Never>?
    
    private var pb = NSPasteboard.general
    
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
    
    private func copyToClipboard(_ text: String, concealed: Bool = false) {
        pb.clearContents()
        pb.setString(text, forType: .string)
        if concealed {
            pb.setData(Data(), forType: .concealed)
        }
        let count = pb.changeCount
        show(.copied)
        clearClipboardTask?.cancel()
        if concealed {
            clearClipboardTask = Task {
                do {
                    try await Task.sleep(for: .seconds(30))
                    
                    if count == pb.changeCount {
                        pb.clearContents()
                        show(.cleared)
                    }
                } catch  { }
            }
        }
    }
    
    var body: some View {
        HStack {
            List(store.displayClips, selection: $selection) { clip in
                HStack {
                    Text(clip.isMasked ? clip.mask : clip.firstLine).help(clip.isMasked ? "" : clip.text)
                    if clip.isLocked {
                        Spacer()
                        if clip.isMasked {
                            Image(systemName: "eye.slash")
                        }
                        Image(systemName: "lock.fill")
                    }
                }
                
            }.sheet(item: $editingClip) { clip in
                PropertiesView(clip: clip) { updated in
                    store.update(updated)
                }
            }.listStyle(.bordered)
                .contextMenu(forSelectionType: Clip.ID.self) { ids in
                    if let id = ids.first, let clip = store[id] {
                        Button("Copy") {
                            copyToClipboard(clip.text)
                        }
                        
                        Button("Remove") {
                            store.remove(clip.id)
                        }.disabled(clip.isLocked)
                        
                        Button("Properties…") {
                            editingClip = clip
                        }
                    }
                } primaryAction: { ids in
                    if let id = ids.first, let clip = store[id] {
                        copyToClipboard(clip.text, concealed: clip.isMasked)
                    }
                }
            
            VStack {
                
                Button {
                    if let text = pb.string(forType: .string), !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        store.add(text)
                    }
                } label: {
                    Text("Add")
                        .frame(maxWidth: .infinity)
                }.keyboardShortcut("v", modifiers: .command)
                
                Button {
                    if let selection {
                        store.remove(selection)
                    }
                    selection = nil
                } label: {
                    Text("Remove")
                        .frame(maxWidth: .infinity)
                }.disabled(selectedClip?.isLocked ?? true)
                
                Button {
                    store.removeAll()
                    selection = nil
                } label: {
                    Text("Clear")
                        .frame(maxWidth: .infinity)
                }.disabled(store.clips.isEmpty)
                
                Spacer()
            }.frame(maxWidth: 100)
        }.padding()
            .frame(minWidth: 500, minHeight: 350)
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
}

extension NSPasteboard.PasteboardType {
    static let concealed = Self("org.nspasteboard.ConcealedType")
}
