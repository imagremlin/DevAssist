//
//  Clip.swift
//  MyApp
//
//  Created by Luis on 29/10/2026.
//

import Foundation

struct Clip: Identifiable, Codable {
    var id = UUID()
    var text: String
    var isLocked = false
    var title = ""
    var isSensitive = false
    var lastUsed: Date?
    var displayText: String {
        let source = !title.isEmpty ? title
                   : isSensitive    ? "••••••"
                   : text
        return source.trimmingCharacters(in: .whitespacesAndNewlines)
                     .components(separatedBy: .newlines).first ?? ""
    }
    var menuTitle: String {
        displayText.count > 20 ? displayText.prefix(20) + "…" : displayText
    }
    
    var tooltip: String {
        isSensitive ? "" : text
    }
    
    func matches(_ query: String) -> Bool {
        title.localizedCaseInsensitiveContains(query)
            || (!isSensitive && text.localizedCaseInsensitiveContains(query))
    }
}

extension Clip {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let legacy = try decoder.container(keyedBy: LegacyKeys.self)
        
        id = try c.decode(UUID.self, forKey: .id)
        text = try c.decode(String.self, forKey: .text)
        isLocked = try c.decodeIfPresent(Bool.self, forKey: .isLocked) ?? false
        isSensitive = try c.decodeIfPresent(Bool.self, forKey: .isSensitive)
                   ?? legacy.decodeIfPresent(Bool.self, forKey: .isMasked)
                   ?? false
        title = try c.decodeIfPresent(String.self, forKey: .title) ?? ""
        lastUsed = try c.decodeIfPresent(Date.self, forKey: .lastUsed)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, text, isLocked, isSensitive, lastUsed
        case title = "mask"        // property 'title', stored under the old key "mask"
    }
    
    private enum LegacyKeys: String, CodingKey {
        case isMasked
    }
}

