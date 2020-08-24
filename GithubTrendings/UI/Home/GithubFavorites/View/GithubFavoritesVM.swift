//
//  GithubFavoritesVM.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class GithubFavoritesVM: ViewModel {
    private let udManager: UDManager

    fileprivate let selected = PublishSubject<Int>()
    fileprivate let showDetail = PublishSubject<Repo>()

    fileprivate var cells: Observable<[Cell]> {
        return udManager.reposRelay.map { [weak self] dto in
            guard let self = self else { return [] }

            self.reuseBag = DisposeBag()

            return dto.map { repo in
                let cell = Cell(
                    title: repo.owner.login + "/" + repo.name,
                    subtitle: repo.description,
                    bookmarked: true,
                    avatarUrl: repo.owner.avatarUrl
                )

                cell.bookmarkSubject
                    .withLatestFrom(self.udManager.reposRelay)
                    .map {
                        var saved = $0
                        if saved.contains(repo) {
                            saved.remove(repo)
                        } else {
                            saved.insert(repo)
                        }
                        return saved
                    }
                    .bind(to: self.udManager.reposRelay)
                    .disposed(by: self.reuseBag)

                return cell
            }
        }
    }

    private var reuseBag = DisposeBag()

    init(udManager: UDManager) {
        self.udManager = udManager
        super.init()

        selected
            .withLatestFrom(udManager.reposRelay) { Array($1)[$0] }
            .bind(to: showDetail)
            .disposed(by: bag)
    }
}

extension GithubFavoritesVM {
    struct Cell: RepoTableCellLoadable {
        let title: String
        let subtitle: String?
        let bookmarked: Bool
        let avatarUrl: String
        let bookmarkSubject = PublishSubject<Void>()
    }
}

extension Reactive where Base == Inputs<GithubFavoritesVM> {
    var selected: AnyObserver<Int> { base.vm.selected.asObserver() }
}

extension Reactive where Base == Outputs<GithubFavoritesVM> {
    var cells: Driver<[GithubFavoritesVM.Cell]> { base.vm.cells.asDriver(onErrorJustReturn: []) }
    var showDetail: Observable<Repo> { base.vm.showDetail.asObservable() }
}

extension Outputs where Base == GithubFavoritesVM {
    var title: String { return "favorites".localized }
}
