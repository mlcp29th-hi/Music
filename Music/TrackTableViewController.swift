//
//  TrackViewController.swift
//  Music
//
//  Created by 吳承翰 on 2023/2/25.
//

import UIKit

class TrackTableViewController: UITableViewController {
    var tracks = MusicSearchResult.sampleData.tracks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = String(localized: "Music")
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(TrackTableViewCell.self)", for: indexPath) as! TrackTableViewCell
        cell.trackNameLabel?.text = tracks[indexPath.row].name
        cell.artistNameLabel?.text = tracks[indexPath.row].artistName
        cell.collectionNameLabel?.text = tracks[indexPath.row].collectionName
        if let artworkImage = tracks[indexPath.row].artworkImage {
            cell.artworkImageView?.image = artworkImage
        } else {
            cell.artworkImageView?.image = UIImage(systemName: "music.note")
            if let artworkURL = tracks[indexPath.row].artworkURL {
                DispatchQueue.global(qos: .userInitiated).async {
                    URLSession.shared.dataTask(with: URLRequest(url: artworkURL)) { imageData, response, error in
                        if let imageData {
                            self.tracks[indexPath.row].artworkImage = UIImage(data: imageData)
                            DispatchQueue.main.async {
                                let visibleIndexPaths = tableView.indexPathsForVisibleRows ?? []
                                if visibleIndexPaths.contains(indexPath) {
                                    cell.artworkImageView?.image = UIImage(data: imageData)
                                }
                            }
                        }
                    }.resume()
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let image = tracks[indexPath.row].artworkImage {
            (cell as! TrackTableViewCell).artworkImageView?.image = image
        }
    }
}
