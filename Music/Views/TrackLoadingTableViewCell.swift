//
//  TrackLoadingTableViewCell.swift
//  Music
//
//  Created by 吳承翰 on 2023/3/3.
//

import UIKit

class TrackLoadingTableViewCell: UITableViewCell {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var errorMessageLabel: UILabel!
    @IBOutlet var retryButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
