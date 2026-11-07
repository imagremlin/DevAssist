//
//  ClipStore.swift
//  Dev Assist
//
//  Created by Luis on 30/10/2026.
//

import Foundation
import Observation
import CryptoKit

@Observable
class ClipStore {
    
    var encryptionKey : SymmetricKey
    var persistent: Bool
    
    @ObservationIgnored private var pending: [Clip.ID: Clip] = [:]
    
    private var savePath: URL {
        let folder = URL.applicationSupportDirectory.appending(path: "DevAssist")
        return folder.appending(path: "clips.json")
    }
    
    private(set) var clips: [Clip] = [] {
        didSet { save() }
    }
    
    init(persistent: Bool = true) {
        self.persistent = persistent
        encryptionKey = persistent ? Self.loadOrCreateKey()
                                   : SymmetricKey(size: .bits256)
        if persistent { load() }
    }
    
    subscript(id: Clip.ID) -> Clip? {
        clips.first { $0.id == id }
    }
    
    var displayClips: [Clip] {
        clips.sorted { $0.isLocked && !$1.isLocked }
    }
    
    var recentClips: ArraySlice<Clip> {
        clips.sorted { ($0.lastUsed ?? .distantPast) > ($1.lastUsed ?? .distantPast) }.prefix(10)
    }

    static func makeClip(_ text: String) -> Clip? {
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Clip(text: text, title: "", lastUsed: .now)
        }
        return nil
    }
    
    @discardableResult
    func addOrUpdate(_ clip: Clip) -> Clip {
        if let i = clips.firstIndex(where: { $0.id == clip.id }) {
            clips[i] = clip
        } else {
            clips.append(clip)
        }
        return clip
    }
        
    func markUsed(_ clip : Clip) {
        if let i = clips.firstIndex(where: { $0.id == clip.id }) {
            clips[i].lastUsed = .now
        }
    }
        
    func remove(_ id: Clip.ID) {
        clips.removeAll { $0.id == id && !$0.isLocked }
    }
    
    func removeAll() {
        clips.removeAll(where: {!$0.isLocked})
    }
    
    func toggleLock(_ id: Clip.ID) {
        if let i = clips.firstIndex(where: { $0.id == id }) {
            clips[i].isLocked.toggle()
        }
    }

    func addPending(_ clip: Clip) {
        pending[clip.id] = clip
    }
    func pendingClip(_ id: Clip.ID) -> Clip? {
        pending[id]
    }
    
    func discardPending(_ id: Clip.ID) {
        pending[id] = nil
    }
    
    private func load() {
        do {
            let fileData = try Data(contentsOf: savePath)
            let box = try AES.GCM.SealedBox(combined: fileData)
            let jsonData = try AES.GCM.open(box, using: encryptionKey)
            clips = try JSONDecoder().decode([Clip].self, from: jsonData)
        } catch {
            
            let stamp = Int(Date.now.timeIntervalSince1970)
            let backup = savePath.deletingLastPathComponent()
                                 .appending(path: "clips-\(stamp).bak")
            try? FileManager.default.moveItem(at: savePath, to: backup)
            
            print("Load Failed: \(error)")
        }
    }
    
    private func save() {
        guard persistent else { return }
        do {
            let folder = URL.applicationSupportDirectory.appending(path: "DevAssist")
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let jsonData = try JSONEncoder().encode(clips)
            let sealed = try AES.GCM.seal(jsonData, using: encryptionKey)
            if let data = sealed.combined {
                try data.write(to: savePath)
            }
        } catch {
            print("Save Failed: \(error)")
        }
    }
    
    private static func loadOrCreateKey() -> SymmetricKey {
        
        let loadQuery: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrService as String: "DevAssist",
            kSecAttrAccount as String: "encryptionKey",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(loadQuery as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data {
            return SymmetricKey(data: data)
        } else if status == errSecItemNotFound {
            let newKey = SymmetricKey(size: .bits256)
            
            let addQuery: [String: Any] = [
                kSecClass as String:       kSecClassGenericPassword,
                kSecAttrService as String: "DevAssist",
                kSecAttrAccount as String: "encryptionKey",
                kSecValueData as String: newKey.withUnsafeBytes { Data($0) }
            ]
            
            let status = SecItemAdd(addQuery as CFDictionary, nil)
            
            if status != errSecSuccess {
                fatalError("Keychain save failed: \(status)")
            }
            
            return newKey
        
        } else {
            fatalError("Keychain load failed: \(status)")
        }
    }
}
