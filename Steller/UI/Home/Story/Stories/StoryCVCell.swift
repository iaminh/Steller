//
//  StoryCVCell.swift
//  Steller
//
//  Created by Chu Anh Minh on 9/17/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import UIKit
import SDWebImage

class StoryCVCell: UICollectionViewCell {
    @IBOutlet private weak var imgView: UIImageView! {
        didSet {
            imgView.layer.cornerRadius = 8
            imgView.clipsToBounds = true
        }
    }

    @IBOutlet private weak var topTitleLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!

    override func prepareForReuse() {
        imgView.sd_cancelCurrentImageLoad()
    }

    func config(with cell: StoriesVM.Cell) {
        topTitleLabel.text = cell.title
        descLabel.text = cell.subtitle
        imgView.sd_setImage(with: URL(string: cell.imageURL), placeholderImage: #imageLiteral(resourceName: "clock"), options: .scaleDownLargeImages)
    }
}
