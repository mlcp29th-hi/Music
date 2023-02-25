//
//  MusicSearchResult.swift
//  Music
//
//  Created by 吳承翰 on 2023/2/25.
//

import Foundation

struct MusicSearchResult: Decodable {
    let count: Int
    let tracks: [Track]
    
    enum CodingKeys: String, CodingKey {
        case count = "resultCount"
        case tracks = "results"
    }
}
