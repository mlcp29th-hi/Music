//
//  MusicSearcher.swift
//  Music
//
//  Created by 吳承翰 on 2023/3/2.
//

import Foundation

class MusicSearcher {
    func search(term: String, offset: Int = 0, limit: Int = 10) async throws -> MusicSearchResult {
        if let url = URL(string: "https://itunes.apple.com/search?term=\(term)&media=music&offset=\(offset)&limit=\(limit)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(MusicSearchResult.self, from: data)
            return result
        }
        return MusicSearchResult(count: 0, tracks: [])
    }
}
