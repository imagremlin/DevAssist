//
//  Dev_AssistTests.swift
//  Dev AssistTests
//
//  Created by Luis on 7/11/2026.
//

import Testing
import Foundation

@testable import Dev_Assist

struct LogProcessorTests {
    
    @Test("Keep only prefixed lines")
    func keepsOnlyPrefixedLines() {
        let log = """
            noise line
            TW-1234 something I care about
            more noise
            """
        #expect(LogProcessor.clean(log, prefix: "TW-1234") == "TW-1234 something I care about")
    }
    
    @Test("Return empty string when prefix is empty")
    func emptyPrefix() {
        let log = """
            noise line
            TW-1234 something I care about
            more noise
            """
        #expect(LogProcessor.clean(log, prefix: "") == "")
    }
    
    @Test("Return empty string when there are no prefix matches")
    func noMatches() {
        let log = """
            noise line
            TW-1234 something I care about
            more noise
            """
        #expect(LogProcessor.clean(log, prefix: "TW-5678") == "")
    }

    @Test("Whitespace is trimmed on matching lines")
    func whitespaceIsTrimmed() {
        let log = """
            noise line
            TW-1234 something I care about
            more noise
            TW-1234 something I care about with trailing spaces       
            """
        #expect(LogProcessor.clean(log, prefix: "TW-1234") == """
            TW-1234 something I care about
            TW-1234 something I care about with trailing spaces
            """)
    }

    @Test("Keep only prefixed lines after stray Debug.Write")
    func keepsOnlyPrefixedLinesFromLegacyWrite() {
        let log = """
            noise line
            TW-1234 something I care about
            more noiseTW-1234 something else I care about
            and more noise
            """
        #expect(LogProcessor.clean(log, prefix: "TW-1234") == """
            TW-1234 something I care about
            TW-1234 something else I care about
            """)
    }
    
    @Test("Keep only prefixed lines after my own stray Debug.Write")
    func keepsOnlyPrefixedLinesFromOwnWrite() {
        let log = """
            noise line
            TW-1234 something I care aboutTW-1234 something else I care about
            more noise
            """
        #expect(LogProcessor.clean(log, prefix: "TW-1234") == """
            TW-1234 something I care about
            TW-1234 something else I care about
            """)
    }
    
    @Test("Keep only prefixed lines with Windows EOL markers")
    func keepsOnlyPrefixedLinesWithWindowsEOL() {
        let log = "noise\r\nTW-1234 first\r\nTW-1234 second\r\n"
        #expect(LogProcessor.clean(log, prefix: "TW-1234") == "TW-1234 first\nTW-1234 second")
    }
}

struct ClipStoreTests {
            
    @Test("Don't create clips from empty or whitespace strings", arguments: ["", "   ", "\n"])
    func blankTextMakesNoClip(text: String) {
        #expect(ClipStore.makeClip(text) == nil)
    }
    
    @Test("Clips are added properly")
    func addClip() throws {
        let store = ClipStore(persistent: false)
        let clipId = store.addOrUpdate(Clip(text: "text", title: "title")).id
        
        #expect(store.clips.count == 1)
        #expect(try #require(store[clipId]).text == "text")
    }
    
    @Test("Clips are updated properly")
    func updateClip() throws {
        let store = ClipStore(persistent: false)
        var clip = store.addOrUpdate(Clip(text: "text", title: "title"))
        clip.text = "updated"
        store.addOrUpdate(clip)
        let updatedClip = try #require(store[clip.id])
        
        #expect(store.clips.count == 1)
        #expect(updatedClip.text == "updated")
    }
    
    @Test("LastUsed is updated properly")
    func lastUsedUpdate() throws {
        let store = ClipStore(persistent: false)
        let originalLastUsed: Date = .now.addingTimeInterval(-60)
        let clip = store.addOrUpdate(Clip(text: "text", title: "title", lastUsed: originalLastUsed))
        store.markUsed(clip)
        let updatedClip = try #require(store[clip.id])
        let clipUpdatedLastUsed = try #require(updatedClip.lastUsed)
        
        #expect(originalLastUsed < clipUpdatedLastUsed)
    }
    
    @Test("Recently used clips display first")
    func lastUsedSorting() throws {
        let store = ClipStore(persistent: false)
        let older = store.addOrUpdate(Clip(text: "a", lastUsed: .now.addingTimeInterval(-120)))
        let newer = store.addOrUpdate(Clip(text: "b", lastUsed: .now.addingTimeInterval(-60)))
        
        #expect(store.recentClips.first?.id == newer.id)
        store.markUsed(older)
        #expect(store.recentClips.first?.id == older.id)
    }
    
    @Test("Locked clips survive removeAll")
    func lockedClipSurvivesRemoveAll() throws {
        let store = ClipStore(persistent: false)
        let clipId = store.addOrUpdate(Clip(text: "text", isLocked: true, title: "title")).id
        store.removeAll()
        
        #expect(store[clipId] != nil)
    }
    
    @Test("Remove Clip")
    func removeClip() throws {
        let store = ClipStore(persistent: false)
        let clipId = store.addOrUpdate(Clip(text: "text", title: "title")).id
        
        store.remove(clipId)
        
        #expect(store[clipId] == nil)
    }
    
    @Test("Locked clips cannot be removed")
    func lockedClipIsNotRemoved() throws {
        let store = ClipStore(persistent: false)
        let clipId = store.addOrUpdate(Clip(text: "text", isLocked: true, title: "title")).id
        
        store.remove(clipId)
        
        #expect(store[clipId] != nil)
    }
    
    @Test("ToggleLock functions properly")
    func toggleLock() throws {
        let store = ClipStore(persistent: false)
        let clipId = store.addOrUpdate(Clip(text: "text", title: "title")).id
        
        store.toggleLock(clipId)
        #expect(try #require(store[clipId]).isLocked)
        
        store.toggleLock(clipId)
        let clip = try #require(store[clipId])
        #expect(!clip.isLocked)
    }
    
    @Test("Locked clips display first")
    func lockedClipsSorting() throws {
        let store = ClipStore(persistent: false)
        store.addOrUpdate(Clip(text: "text", title: "title"))
        let lockedClipId = store.addOrUpdate(Clip(text: "text", isLocked: true, title: "title")).id
        
        #expect(store.displayClips[0].id == lockedClipId)
    }
    
    @Test("Empty search returns all clips")
    func emptySearch() throws {
        let store = ClipStore(persistent: false)
        store.addOrUpdate(Clip(text: "text1", title: "title1"))
        store.addOrUpdate(Clip(text: "text2", title: "title2"))
        
        let searchResult = store.clips(matching: "")
        
        #expect(searchResult.count == 2)
    }

    @Test("Search is case insensitive")
    func caseInsensitiveSearch() throws {
        let store = ClipStore(persistent: false)
        let clipId = store.addOrUpdate(Clip(text: "text1", title: "title1")).id
        store.addOrUpdate(Clip(text: "text2", title: "title2"))
        
        let searchResult = store.clips(matching: "TEXT1")
        
        #expect(searchResult.count == 1)
        #expect(searchResult[0].id == clipId)
    }
 
    @Test("Search by title")
    func titleSearch() throws {
        let store = ClipStore(persistent: false)
        store.addOrUpdate(Clip(text: "text1", title: "title1"))
        store.addOrUpdate(Clip(text: "text2", title: "title2"))
        store.addOrUpdate(Clip(text: "nomatch", title: "nomatch"))
        
        let searchResult = store.clips(matching: "title")
        
        #expect(searchResult.count == 2)
    }
    

    @Test("Empty search returns locked clips first")
    func lockedClipsOnEmptySearch() throws {
        let store = ClipStore(persistent: false)
        store.addOrUpdate(Clip(text: "text1", title: "title1"))
        let clip2Id = store.addOrUpdate(Clip(text: "text2", isLocked: true, title: "title2")).id
        
        let searchResult = store.clips(matching: "")
        
        #expect(searchResult.count == 2)
        #expect(searchResult[0].id == clip2Id)
    }

    @Test("Search returns locked clips first")
    func lockedClipsSearch() throws {
        let store = ClipStore(persistent: false)
        store.addOrUpdate(Clip(text: "text1", title: "title1"))
        let clip2Id = store.addOrUpdate(Clip(text: "text2", isLocked: true, title: "title2")).id
        store.addOrUpdate(Clip(text: "nomatch", title: "title1"))
        
        let searchResult = store.clips(matching: "text")
        
        #expect(searchResult.count == 2)
        #expect(searchResult[0].id == clip2Id)
    }

    @Test("Search does not return sensitive clips by text")
    func sensitiveSearchByText() throws {
        let store = ClipStore(persistent: false)
        store.addOrUpdate(Clip(text: "text1", title: "title1", isSensitive: true))
        let clip2Id = store.addOrUpdate(Clip(text: "text2", isLocked: true, title: "title2")).id
        
        let searchResult = store.clips(matching: "text")
        
        #expect(searchResult.count == 1)
        #expect(searchResult[0].id == clip2Id)
    }

    @Test("Search returns sensitive clips by title")
    func sensitiveSearchByTitle() throws {
        let store = ClipStore(persistent: false)
        store.addOrUpdate(Clip(text: "text1", title: "title1", isSensitive: true))
        store.addOrUpdate(Clip(text: "text2", isLocked: true, title: "title2"))
        
        let searchResult = store.clips(matching: "title")
        
        #expect(searchResult.count == 2)
    }

}

struct ClipTests {
    private func decodeClip(_ json: String) throws -> Clip {
        try JSONDecoder().decode(Clip.self, from: Data(json.utf8))
    }
    
    @Test("Legacy 'mask' and 'isMasked' keys map to title and isSensitive")
    func decodesLegacyKeys() throws {
        let json = """
            {
                "id": "6F9619FF-8B86-D011-B42D-00C04FC964FF",
                "text": "secret",
                "mask": "VPN",
                "isMasked": true
            }
            """
        let clip = try decodeClip(json)
        
        #expect(clip.title == "VPN")
        #expect(clip.isSensitive)
    }
    
    @Test("When legacy 'mask' and current 'title' keys are present, current wins")
    func decodesLegacyAndCurrentKeys() throws {
        let json = """
            {
                "id": "6F9619FF-8B86-D011-B42D-00C04FC964FF",
                "text": "secret",
                "mask": "mask",
                "title": "title",
                "isMasked": true
            }
            """
        let clip = try decodeClip(json)
        
        #expect(clip.title == "title")
        #expect(clip.isSensitive)
    }
    
    @Test("Defaults are honoured")
    func decodeHonoursDefaults() throws {
        let json = """
            {
                "id": "6F9619FF-8B86-D011-B42D-00C04FC964FF",
                "text": "secret"
            }
            """
        let clip = try decodeClip(json)
        
        #expect(!clip.isLocked)
        #expect(!clip.isSensitive)
        #expect(clip.title == "")
        #expect(clip.lastUsed == nil)
    }
        
    @Test("Encoding writes ‘title’, not the legacy keys")
    func encodesNewKeys() throws {
        let clip = Clip(text: "secret", title: "VPN", isSensitive: true)
        let data = try JSONEncoder().encode(clip)
        let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        
        #expect(object["title"] as? String == "VPN")
        #expect(object["mask"] == nil)
        #expect(object["isMasked"] == nil)
    }

    @Test("Can successfully encode/decode a clip")
    func encodeDecode() throws {
        let clip1 = Clip(text: "text", isLocked: true, title: "title", isSensitive: true, lastUsed: .now )
        let jsonData = try JSONEncoder().encode(clip1)
        let clip2 = try JSONDecoder().decode(Clip.self, from: jsonData)
        
        #expect(clip1 == clip2)
    }
    
    @Test("Clip DisplayText functions properly")
    func displayText() throws {
        let clip1 = Clip(text: "Text")
        let clip2 = Clip(text: "Multiline Text\nLine2")
        let clip3 = Clip(text: "Text", title: "Title")
        
        #expect(clip1.displayText == "Text")
        #expect(clip2.displayText == "Multiline Text")
        #expect(clip3.displayText == "Title")
    }

    @Test("Clip MenuTitle functions properly")
    func menuTitle() throws {
        let clip1 = Clip(text: "Text")
        let clip2 = Clip(text: "Multiline Text\nLine2")
        let clip3 = Clip(text: "Text", title: "Title")
        let clip4 = Clip(text: "Text", title: "Long Title12345678901234567890")
        let clip5 = Clip(text: "Text", title: "Long Title1234567890")
  
        #expect(clip1.menuTitle == "Text")
        #expect(clip2.menuTitle == "Multiline Text")
        #expect(clip3.menuTitle == "Title")
        #expect(clip4.menuTitle == "Long Title1234567890…")
        #expect(clip5.menuTitle == "Long Title1234567890")
    }
    
  
    @Test("Sensitive flag functions properly")
    func sensitiveClip() throws {
        let clip1 = Clip(text: "Text", title: "Title", isSensitive: true)
        let clip2 = Clip(text: "Text", isSensitive: true)
       
        #expect(clip1.displayText == "Title")
        #expect(clip1.menuTitle == "Title")
        #expect(clip1.tooltip == "")
        
        #expect(clip2.displayText == "••••••")
        #expect(clip2.menuTitle == "••••••")
        #expect(clip2.tooltip == "")
    }
    
    @Test("Clips are matched properly")
    func matches() throws {
        let clip = Clip(text: "Text Match", title: "Title Match")
        
        #expect(clip.matches("text"))
        #expect(clip.matches("title"))
        #expect(!clip.matches("nomatch"))
    }
    
    @Test("Sensitive clips are matched properly")
    func sensitiveMatches() throws {
        let clip = Clip(text: "Text Match", title: "Title Match", isSensitive: true)
        
        #expect(!clip.matches("text"))
        #expect(clip.matches("title"))
        #expect(!clip.matches("nomatch"))
    }
}
