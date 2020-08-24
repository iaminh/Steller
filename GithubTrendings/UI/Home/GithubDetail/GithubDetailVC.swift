//
//  GithubDetailVC.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import UIKit
import RxSwift

class GithubDetailVC: Controller<GithubDetailVM> {
    @IBOutlet private var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.text = vm.out.description
        }
    }
    @IBOutlet private var languageLabel: UILabel! {
        didSet {
            languageLabel.text = vm.out.language
        }
    }
    @IBOutlet private var forksLabel: UILabel! {
        didSet {
            forksLabel.text = vm.out.forks
        }
    }
    @IBOutlet private var starsLabel: UILabel! {
        didSet {
            starsLabel.text = vm.out.stars
        }
    }
    @IBOutlet private var dateLabel: UILabel! {
        didSet {
            dateLabel.text = vm.out.created
        }
    }
    @IBOutlet private var openGitButton: UIButton! {
        didSet {
            openGitButton.setTitle("open_git".localized, for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = vm.out.title
    }

    override func bindToVM() {
        super.bindToVM()

        openGitButton.rx
            .tap
            .bind(to: vm.in.rx.openGithubButtonTap)
            .disposed(by: bag)
    }
}
