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


extension StoriesVM {
    struct Cell {
        let title: String
        let subtitle: String
        let imageURL: String
    }
}

class StoriesVM: ViewModel {
    private let dataProvider: DataProvider

    fileprivate let stories = BehaviorRelay<[Story]>(value: [])
    fileprivate let selected = PublishSubject<Int>()
    fileprivate let showDetail = PublishSubject<([Story], Int)>()
    fileprivate let cells = BehaviorRelay<[Cell]>(value: [])

    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider

        super.init()
        bindRx()
    }

    private func bindRx() {
        dataProvider.loadStories()
            .bind(to: stories)
            .disposed(by: bag)

        stories
            .map { $0.map { Cell(title: $0.user.displayName, subtitle: "My name is, \($0.user.displayName)", imageURL: $0.coverSrc) } }
            .bind(to: cells)
            .disposed(by: bag)

        selected
            .withLatestFrom(stories) { ($1, $0) }
            .bind(to: showDetail)
            .disposed(by: bag)
    }
}

extension Reactive where Base == Inputs<StoriesVM> {
    var selected: AnyObserver<Int> { base.vm.selected.asObserver() }
}

extension Reactive where Base == Outputs<StoriesVM> {
    var cells: Driver<[StoriesVM.Cell]> { base.vm.cells.asDriver(onErrorJustReturn: []) }
    var showDetail: Observable<([Story], Int)> { base.vm.showDetail.asObservable() }
}

extension Outputs where Base == StoriesVM {
    var title: String { return "Stories".localized }
}
