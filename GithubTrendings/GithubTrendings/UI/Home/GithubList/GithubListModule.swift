//
//  GithubListModule.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import UIKit
import RxSwift

class GithubListModule: Module {
    override func toPresentable() -> UIViewController {
        return router.toPresentable()
    }

    private lazy var rootVC = GithubListVC(
        viewModel: GithubListVM(
            dataProvider: GithubDataProvider(),
            udManager: udManager
        )
    )

    private let udManager: UDManager

    private lazy var onShowDetail: (Repo) -> Void = { [weak self] repo in
        let openURL: (URL) -> Void = { UIApplication.shared.open($0) }

        let vm = GithubDetailVM(repo: repo)

        vm.out.rx
            .openUrl
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: openURL)
            .disposed(by: vm.bag)

        let vc = GithubDetailVC(viewModel: vm)

        self?.router.push(vc)
    }

    init(router: Router, udManager: UDManager) {
        self.udManager = udManager
        super.init(router: router)
        router.setRoot(rootVC)

        rootVC.vm.out.rx
            .showDetail
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: onShowDetail)
            .disposed(by: bag)

    }
}
