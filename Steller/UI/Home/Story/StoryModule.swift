//
//  GithubListModule.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import UIKit
import RxSwift

class StoryModule: Module {
    override func toPresentable() -> UIViewController {
        return router.toPresentable()
    }

    private lazy var rootVC = StoriesVC(
        viewModel: StoriesVM(
            dataProvider: DataProvider()
        )
    )

    private lazy var onShowPager: ([Story], Int) -> Void = { [weak self] stories, index in
        let vcs = stories.map { StoryDetailVC(viewModel: StoryDetailVM(story: $0)) }
        self?.router.present(StoryPagerVC(vcs: vcs))
    }

    override init(router: Router) {
        super.init(router: router)
        router.setRoot(rootVC)

        rootVC.vm.out.rx
            .showDetail
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: onShowPager)
            .disposed(by: bag)
    }
}
