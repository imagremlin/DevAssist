import SwiftUI

struct ContentView: View {
    
    @State private var store = ClipStore()
    @State private var selection: Clip.ID?
    @State private var editingClip: Clip?
    @State private var showCopied = false
    
    private var pb = NSPasteboard.general
    
    private var selectedClip: Clip? {
        selection.flatMap { store[$0] }
    }
    
    func copyToClipboard(_ text : String) {
        pb.clearContents()
        pb.setString(text, forType: .string)
        showCopied = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation { showCopied = false }
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
                        copyToClipboard(clip.text)
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
                if showCopied {
                    VStack {
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: 40))
                        Text("Copied")
                    }.padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                }
            }
    }
}

