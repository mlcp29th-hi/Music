//
//  TrackDetailViewController.swift
//  Music
//
//  Created by 吳承翰 on 2023/3/9.
//

import UIKit

class TrackDetailViewController: UIViewController {
    var trackID: Int!
    var track: Track? {
        didSet {
            UIView.transition(with: view, duration: 0.35, options: .transitionCrossDissolve) {
                self.fillTrackInfoToUI()
            }
        }
    }
    var searchError: Error? {
        didSet {
            if let searchError {
                retryButton?.isHidden = false
                errorMessageLabel?.isHidden = false
                errorMessageLabel?.text = searchError.localizedDescription
            } else {
                retryButton?.isHidden = true
                errorMessageLabel?.isHidden = true
            }
        }
    }
    @IBOutlet var trackNameLabel: UILabel?
    @IBOutlet var artworkImageView: UIImageView?
    @IBOutlet var collectionNameLabel: UILabel?
    @IBOutlet var artistNameLabel: UILabel?
    @IBOutlet var releaseDateLabel: UILabel?
    @IBOutlet var trackPlayButton: UIButton?
    @IBOutlet var artistPreviewButton: UIButton?
    @IBOutlet var collectionPreviewButton: UIButton?
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView?
    @IBOutlet var retryButton: UIButton?
    @IBOutlet var errorMessageLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator?.stopAnimating()
        retryButton?.isHidden = true
        errorMessageLabel?.isHidden = true
        if let track, track.artworkURL != nil, track.previewURL != nil {
            if track.artworkImage == nil {
                loadArtworkImage()
            }
        } else {
            loadTrack()
        }
        fillTrackInfoToUI()
    }
    
    @IBAction func showPreview(_ sender: UIButton) {
        switch sender {
        case trackPlayButton:
            return
        case collectionPreviewButton:
            return
        case artistPreviewButton:
            return
        default:
            return
        }
    }
    
    @IBAction private func loadTrack() {
        loadingIndicator?.startAnimating()
        Task {
            let searcher = MusicSearcher()
            do {
                track = try await searcher.lookup(trackID: trackID).tracks.first
            } catch {
                searchError = error
                loadingIndicator?.stopAnimating()
                return
            }
            searchError = nil
            loadingIndicator?.stopAnimating()
            loadArtworkImage()
        }
    }
    
    private func loadArtworkImage() {
        Task {
            if let url = track?.artworkURL {
                let (imageData, _) = try await URLSession.shared.data(from: url)
                track?.artworkImage = UIImage(data: imageData)
            }
        }
    }
    
    private func fillTrackInfoToUI() {
        trackNameLabel?.text = track?.name ?? String(localized: "Track")
        trackNameLabel?.textColor = track?.name != nil ? .label : .placeholderText
        
        artworkImageView?.image = track?.artworkImage ?? UIImage(systemName: "music.note")
        
        collectionNameLabel?.text = track?.collectionName ?? String(localized: "Collection")
        collectionNameLabel?.textColor = track?.collectionName != nil ? .label : .placeholderText
        
        artistNameLabel?.text = track?.artistName ?? String(localized: "Artist")
        artistNameLabel?.textColor = track?.artistName != nil ? .label : .placeholderText
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        if let releaseDate = track?.releaseDate {
            releaseDateLabel?.text = dateFormatter.string(from: releaseDate)
        }
        releaseDateLabel?.textColor = track?.releaseDate != nil ? .label : .placeholderText
        
        trackPlayButton?.isEnabled = track?.previewURL != nil
        collectionPreviewButton?.isEnabled = track?.collectionViewURL != nil
        artistPreviewButton?.isEnabled = track?.artistViewURL != nil
    }
}
