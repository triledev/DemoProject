//
//  FeedItemCell.swift
//  Prototype
//
//  Created by Tri Le on 9/20/22.
//

import UIKit

final class FeedItemCell: UITableViewCell {
    @IBOutlet private(set) var locationContainer: UIView!
    @IBOutlet private(set) var locationLabel: UILabel!
    @IBOutlet private(set) var feedItemView: UIImageView!
    @IBOutlet private(set) var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        feedItemView.alpha = 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        feedItemView.alpha = 0
    }

    func fadeIn(_ image: UIImage?) {
        feedItemView.image = image

        UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: { self.feedItemView.alpha = 1 })
    }
}
