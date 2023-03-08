//
//  TrackViewController.swift
//  Music
//
//  Created by 吳承翰 on 2023/2/25.
//

import UIKit

class TrackTableViewController: UITableViewController {
    var tracks: [Track] = []
    var loadingStatus: LoadingStatus = .notLoading
    var noMoreTracks = false
    let searcher = MusicSearcher()
    var searchTerm = ""
    var searchError: Error?
    
    enum LoadingStatus {
        case loading
        case notLoading
        case failed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = String(localized: "Music")
        navigationItem.searchController = UISearchController()
        navigationItem.searchController?.searchBar.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        loadingStatus == .notLoading ? tracks.count : tracks.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if loadingStatus != .notLoading && indexPath.row == tracks.count {
            let loadingIndicatorCell = tableView.dequeueReusableCell(withIdentifier: "\(TrackLoadingTableViewCell.self)", for: indexPath) as! TrackLoadingTableViewCell
            if let searchError {
                loadingIndicatorCell.activityIndicator?.stopAnimating()
                loadingIndicatorCell.retryButton.isHidden = false
                loadingIndicatorCell.errorMessageLabel.text = searchError.localizedDescription
                loadingIndicatorCell.errorMessageLabel.isHidden = false
            } else {
                loadingIndicatorCell.activityIndicator?.startAnimating()
                loadingIndicatorCell.retryButton.isHidden = true
                loadingIndicatorCell.errorMessageLabel.isHidden = true
            }
            return loadingIndicatorCell
        }
        
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
        if indexPath.row == tracks.count - 1 && !noMoreTracks && loadingStatus == .notLoading  {
            loadTracks()
            return
        }
        guard indexPath.row < tracks.count else { return }
        if let image = tracks[indexPath.row].artworkImage {
            (cell as! TrackTableViewCell).artworkImageView?.image = image
        }
    }
    
    @IBAction func loadTracks() {
        loadingStatus = .loading
        searchError = nil
        tableView.reloadData()
        Task {
            do {
                let searchResult = try await searcher.search(term: searchTerm, offset: tracks.count)
                tracks.append(contentsOf: searchResult.tracks)
                loadingStatus = .notLoading
                noMoreTracks = searchResult.count != 10
                tableView.reloadData()
            } catch {
                searchError = error
                loadingStatus = .failed
                tableView.reloadData()
            }
        }
    }
}

extension TrackTableViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        let trimmedText = text.trimmingCharacters(in: .whitespaces)
        searchBar.text = trimmedText
        guard !trimmedText.isEmpty else { return }
        searchTerm = text
        tracks = []
        tableView.reloadData()
        loadTracks()
    }
}
