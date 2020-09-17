//
//  GithubDetailVC.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import UIKit
import RxSwift

class StoryDetailVC: Controller<StoryDetailVM> {
    @IBOutlet private weak var imgView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.text = vm.out.description
        }
    }

    @IBOutlet private weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = vm.out.title
        descriptionLabel.text = vm.out.description
        imgView.sd_setImage(with: URL(string: vm.out.imageURL),
                            placeholderImage: #imageLiteral(resourceName: "clock"),
                            options: .scaleDownLargeImages)
    }
}
