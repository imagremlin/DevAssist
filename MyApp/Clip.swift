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
    var isMasked = false
    var mask: String
    var firstLine: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines).first ?? ""
    }
}

extension Clip {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        text = try c.decode(String.self, forKey: .text)
        isLocked = try c.decodeIfPresent(Bool.self, forKey: .isLocked) ?? false
        isMasked = try c.decodeIfPresent(Bool.self, forKey: .isMasked) ?? false
        mask = try c.decodeIfPresent(String.self, forKey: .mask) ?? ""
    }
}

