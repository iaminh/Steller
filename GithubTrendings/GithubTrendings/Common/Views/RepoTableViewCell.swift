//
//  RepoTableViewCell.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import UIKit
import SDWebImage
import RxSwift

class RepoTableViewCell: UITableViewCell {
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var mainTitleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var bookmarkButton: UIButton!

    private var bag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }

    func config(with cell: GithubListVM.Cell) {
        mainTitleLabel.text = cell.title
        descriptionLabel.text = cell.subtitle
        avatarImageView.sd_setImage(with: URL(string: cell.avatarUrl), placeholderImage: #imageLiteral(resourceName: "user"))
        bookmarkButton.setImage(cell.bookmarked ? #imageLiteral(resourceName: "bookmark-f") : #imageLiteral(resourceName: "bookmark"), for: .normal)
        bookmarkButton.rx.tap.bind(to: cell.bookmarkSubject).disposed(by: bag)
    }
}
