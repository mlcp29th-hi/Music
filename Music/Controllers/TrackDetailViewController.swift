//
//  TrackDetailViewController.swift
//  Music
//
//  Created by 吳承翰 on 2023/3/9.
//

import UIKit
import Combine

class TrackDetailViewController: UIViewController {
    var trackID: Int!
    var track: Track? {
        didSet {
            UIView.transition(with: view, duration: 0.35, options: .transitionCrossDissolve) {
                self.fillTrackInfoToUI()
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
    
    private var loadingStatusViewController: LoadingStatusViewController!
    private var cancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingStatusViewController = (children.first { type(of: $0) === LoadingStatusViewController.self } as! LoadingStatusViewController)
        cancellable = loadingStatusViewController.retryLoadingPublisher
            .receive(on: RunLoop.main)
            .sink { [unowned self] in
                self.loadTrack()
            }
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
        let url: URL? = {
            switch sender {
            case trackPlayButton:
                return track?.previewURL
            case collectionPreviewButton:
                return track?.collectionViewURL
            case artistPreviewButton:
                return track?.artistViewURL
            default:
                return nil
            }
        }()
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(TrackPreviewViewController.self)") as! TrackPreviewViewController
        controller.url = url
        if let sheet = controller.sheetPresentationController {
            sheet.detents = sender == trackPlayButton ? [.medium()] : [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(controller, animated: true)
    }
    
    @IBAction private func loadTrack() {
        loadingStatusViewController.startLoadingAnimation()
        Task {
            let searcher = MusicSearcher()
            do {
                track = try await searcher.lookup(trackID: trackID).tracks.first
            } catch {
                loadingStatusViewController.stopLoadingAnimation(with: error)
                return
            }
            loadingStatusViewController.stopLoadingAnimation()
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
