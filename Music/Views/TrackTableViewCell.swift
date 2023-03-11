//
//  TrackTableViewCell.swift
//  Music
//
//  Created by 吳承翰 on 2023/3/2.
//

import UIKit

class TrackTableViewCell: UITableViewCell {
    @IBOutlet var trackNameLabel: UILabel?
    @IBOutlet var artistNameLabel: UILabel?
    @IBOutlet var collectionNameLabel: UILabel?
    @IBOutlet var artworkImageView: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
