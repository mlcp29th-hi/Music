//
//  Track.swift
//  Music
//
//  Created by 吳承翰 on 2023/2/25.
//

import UIKit

struct Track: Decodable {
    let id: Int
    let name: String
    let artworkURL: URL?
    var artworkImage: UIImage? = nil
    
    let artistName: String
    let artistViewURL: URL
    
    let collectionName: String
    let collectionViewURL: URL
    
    let previewURL: URL?
    
    let releaseDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case name = "trackName"
        case artworkURL = "artworkUrl100"
        case artistName = "artistName"
        case artistViewURL = "artistViewUrl"
        case collectionName = "collectionName"
        case collectionViewURL = "collectionViewUrl"
        case previewURL = "previewUrl"
        case releaseDate = "releaseDate"
    }
}
