//
//  LoadingStatusViewController.swift
//  Music
//
//  Created by 吳承翰 on 2023/3/21.
//

import UIKit
import Combine

class LoadingStatusViewController: UIViewController {
    private var showLoadingAnimation = false {
        didSet {
            if showLoadingAnimation {
                loadingIndicator?.isHidden = false
                loadingIndicator?.startAnimating()
            } else {
                loadingIndicator?.isHidden = true
                loadingIndicator?.stopAnimating()
            }
        }
    }
    private var error: Error? {
        didSet {
            if let error {
                retryButton?.isHidden = false
                errorMessageLabel?.text = error.localizedDescription
                errorMessageLabel?.isHidden = false
            } else {
                retryButton?.isHidden = true
                errorMessageLabel?.text = nil
                errorMessageLabel?.isHidden = true
            }
        }
    }
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView?
    @IBOutlet private var retryButton: UIButton?
    @IBOutlet private var errorMessageLabel: UILabel?
    
    let retryLoadingPublisher = PassthroughSubject<Void, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator?.isHidden = true
        retryButton?.isHidden = true
        errorMessageLabel?.isHidden = true
    }
    
    func startLoadingAnimation() {
        view.isHidden = false
        showLoadingAnimation = true
        error = nil
    }
    
    func stopLoadingAnimation(with error: Error? = nil) {
        showLoadingAnimation = false
        self.error = error
        view.isHidden = true
    }
    
    @IBAction private func requestRetryLoading() {
        retryLoadingPublisher.send()
    }
}
