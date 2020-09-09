//
//  GithubDetailVM.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GithubDetailVM: ViewModel {
    fileprivate let repo: Repo
    fileprivate let openGithub = PublishSubject<Void>()
    fileprivate let openUrl = PublishSubject<URL>()

    init(repo: Repo) {
        self.repo = repo
        super.init()

        openGithub
            .compactMap { URL(string: repo.htmlUrl) }
            .bind(to: openUrl)
            .disposed(by: bag)
    }
}

extension Reactive where Base == Inputs<GithubDetailVM> {
    var openGithubButtonTap: AnyObserver<Void> { base.vm.openGithub.asObserver() }
}

extension Reactive where Base == Outputs<GithubDetailVM> {
    var openUrl: Observable<URL> { base.vm.openUrl.asObservable() }
}

extension Outputs where Base == GithubDetailVM {
    var title: String { return  vm.repo.owner.login + "/" + vm.repo.name }
    var description: String { return vm.repo.description ?? "description_placeholder".localized }
    var language: String { return vm.repo.language ?? "language_placeholder".localized }
    var stars: String { return "stars_count".localize(with: [String(vm.repo.stargazersCount)]) }
    var forks: String { return "forks_count".localize(with: [String(vm.repo.forks)]) }
    var created: String { return "created_at".localize(with: [vm.repo.createdAt.toDayString()]) }
}
