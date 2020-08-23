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
    private let dataProvider: GithubDataProvider
    private let udManager: UDManager

    fileprivate (set) lazy var lastDayRepos: BehaviorSubject<[Repo]> = {
        let subject = BehaviorSubject<[Repo]>(value: [])
        self.dataProvider
            .loadRepos(for: .day, page: 0, perPage: 1)
            .bind(to: subject)
            .disposed(by: bag)
        return subject
    }()

    fileprivate (set) lazy var lastWeekRepos: BehaviorSubject<[Repo]> = {
        let subject = BehaviorSubject<[Repo]>(value: [])
        self.dataProvider
            .loadRepos(for: .week, page: 0, perPage: 3)
            .bind(to: subject)
            .disposed(by: bag)
        return subject
    }()

    fileprivate (set) lazy var lastMonthRepos: BehaviorSubject<[Repo]> = {
        let subject = BehaviorSubject<[Repo]>(value: [])
        self.dataProvider
            .loadRepos(for: .month, page: 0, perPage: 5)
            .bind(to: subject)
            .disposed(by: bag)
        return subject
    }()

    fileprivate let segmentSwitched = PublishSubject<Int>()
    fileprivate let selected = PublishSubject<Int>()
    fileprivate let loadNext = PublishSubject<Void>()

    private var currentInterval = BehaviorSubject<Interval>(value: .day)

    fileprivate var cells = BehaviorSubject<[Cell]>(value: [])
    fileprivate var currentRepos = BehaviorSubject<[Repo]>(value: [])

    private var reuseBag = DisposeBag()

    init(dataProvider: GithubDataProvider, udManager: UDManager) {
        self.dataProvider = dataProvider
        self.udManager = udManager

        super.init()

        bindRx()
    }

    private func bindRx() {
        segmentSwitched
            .skip(1)
            .map { Interval.allCases[$0] }
            .bind(to: currentInterval)
            .disposed(by: bag)

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
            .bind(to: cells)
            .disposed(by: bag)

        Observable.combineLatest(currentInterval.filter { $0 == .day }, lastDayRepos)
            .map { $1 }
            .bind(to: currentRepos)
            .disposed(by: bag)

        Observable.combineLatest(currentInterval.filter { $0 == .week }, lastWeekRepos)
            .map { $1 }
            .bind(to: currentRepos)
            .disposed(by: bag)

        Observable.combineLatest(currentInterval.filter { $0 == .month }, lastMonthRepos)
            .map { $1 }
            .bind(to: currentRepos)
            .disposed(by: bag)
    }
}

extension GithubListVM {
    struct Cell {
        let title: String
        let subtitle: String
        let bookmarked: Bool
        let avatarUrl: String

        let bookmarkSubject = PublishSubject<Void>()
    }
}

extension Reactive where Base == Inputs<GithubListVM> {
    var segmentSwitched: AnyObserver<Int> { base.vm.segmentSwitched.asObserver() }
    var selected: AnyObserver<Int> { base.vm.selected.asObserver() }
    var loadNext: AnyObserver<Void> { base.vm.loadNext.asObserver() }
}

extension Reactive where Base == Outputs<GithubListVM> {
    var cells: Driver<[GithubListVM.Cell]> { base.vm.cells.asDriver(onErrorJustReturn: []) }
}

extension Outputs where Base == GithubListVM {
    var title: String { return "repositories".localized }
    var segments: [String] { return Interval.allCases.map { $0.localizedTitle }  }
}
