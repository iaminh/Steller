//
//  GithubListModule.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import UIKit

class GithubListModule: Module {
    override func toPresentable() -> UIViewController {
        return router.toPresentable()
    }

    private let rootVC = GithubListVC(
        viewModel: GithubListVM(
            dataProvider: GithubDataProvider(),
            udManager: UDManager()
        )
    )

    override init(router: Router) {
        super.init(router: router)
        router.setRoot(rootVC)
    }
}
