//
//  TrackPreviewViewController.swift
//  Music
//
//  Created by 吳承翰 on 2023/3/22.
//

import UIKit
import WebKit
import Combine

class TrackPreviewViewController: UIViewController {
    var url: URL?
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var toolbar: UIToolbar!
    @IBOutlet private var errorMessageLabel: UILabel!
    
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!
    var space: UIBarButtonItem!
    var safariButton: UIBarButtonItem!
    
    private var cancellableSet = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.isHidden = true
        errorMessageLabel.isHidden = true
        backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(goBack))
        forwardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.forward"), style: .plain, target: self, action: #selector(goForward))
        reloadButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(loadWebsite))
        space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        safariButton = UIBarButtonItem(image: UIImage(systemName: "safari"), style: .plain, target: self, action: #selector(openInSafari))
        webView.navigationDelegate = self
        loadWebsite()
        toolbar.setItems([backButton, forwardButton, reloadButton, space, safariButton], animated: true)
        
        webView.publisher(for: \.estimatedProgress)
            .receive(on: RunLoop.main)
            .sink { progress in
                if progress <= 0.1 {
                    self.progressView.progress = 0.1
                }
                self.progressView.setProgress(Float(progress), animated: true)
            }
            .store(in: &cancellableSet)
        
        webView.publisher(for: \.canGoBack)
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: backButton)
            .store(in: &cancellableSet)
        
        webView.publisher(for: \.canGoForward)
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: forwardButton)
            .store(in: &cancellableSet)
        
        webView.publisher(for: \.isLoading)
            .receive(on: RunLoop.main)
            .sink { isLoading in
                UIView.transition(with: self.view, duration: 0.25, options: .transitionCrossDissolve) {
                    self.progressView.isHidden = !isLoading
                    if isLoading {
                        self.webView.isHidden = false
                        self.errorMessageLabel.isHidden = true
                    }
                }
            }
            .store(in: &cancellableSet)
        
        webView.publisher(for: \.url)
            .receive(on: RunLoop.main)
            .assign(to: \.url, on: self)
            .store(in: &cancellableSet)
    }
    
    @objc func loadWebsite() {
        guard let url else { return }
        progressView.progress = 0.1
        webView.load(URLRequest(url: url))
    }
    
    @objc private func goBack() {
        webView.goBack()
    }
    
    @objc private func goForward() {
        webView.goForward()
    }
    
    @objc private func openInSafari() {
        if let url {
            UIApplication.shared.open(url)
        }
    }
}

extension TrackPreviewViewController: WKNavigationDelegate {    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webView.isHidden = true
        self.errorMessageLabel.isHidden = false
        self.errorMessageLabel.text = error.localizedDescription
    }
}
