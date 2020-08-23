//
//  GithubListVm.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private typealias Interval = GithubDataProvider.Interval

class GithubListVM: ViewModel {
    struct Cell {
        let title: String
        let subtitle: String
        let bookmarked: Bool
        let avatarUrl: String

        let bookmarkSubject = PublishSubject<Void>()
    }

    private let dataProvider: GithubDataProvider
    private let udManager: UDManager

    fileprivate (set) lazy var lastDayRepos = dataProvider.loadRepos(for: .day)
    fileprivate (set) lazy var lastWeekRepos = dataProvider.loadRepos(for: .week)
    fileprivate (set) lazy var lastMonthRepos = dataProvider.loadRepos(for: .month)
    fileprivate let segmentSwitched = PublishSubject<Int>()
    fileprivate let selected = PublishSubject<Int>()

    private var currentInterval = BehaviorSubject<Interval>(value: .day)

    private var currentRepos: Observable<[Repo]> {
        currentInterval.flatMap { [unowned self] interval -> Observable<[Repo]> in
            switch interval {
            case .day:
                return self.lastDayRepos
            case .month:
                return self.lastMonthRepos
            case .week:
                return self.lastWeekRepos
            }
        }
    }

    private var reuseBag = DisposeBag()
    fileprivate var cells: Observable<[Cell]> {
        Observable.combineLatest(currentRepos, udManager.reposRelay)
            .map { [weak self] dto, saved -> [Cell] in
                guard let self = self else { return [] }

                self.reuseBag = DisposeBag()

                return dto.map { repo in
                    let cell = Cell(
                        title: repo.name,
                        subtitle: repo.description,
                        bookmarked: saved.contains(repo),
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

    init(dataProvider: GithubDataProvider, udManager: UDManager) {
        self.dataProvider = dataProvider
        self.udManager = udManager

        super.init()

        segmentSwitched
            .map { Interval.allCases[$0] }
            .bind(to: currentInterval)
            .disposed(by: bag)
    }
}

extension Reactive where Base == Inputs<GithubListVM> {
    var segmentSwitched: AnyObserver<Int> { base.vm.segmentSwitched.asObserver() }
    var selected: AnyObserver<Int> { base.vm.selected.asObserver() }
}

extension Reactive where Base == Outputs<GithubListVM> {
    var cells: Driver<[GithubListVM.Cell]> { base.vm.cells.asDriver(onErrorJustReturn: []) }
}
