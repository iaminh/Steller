//
//  UDManager.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UDManager {
    private let disposeBag = DisposeBag()
    private let reposKey = "reposKey"

    private var repos: [Repo] {
        get {
            return UserDefaults.standard.array(forKey: "bookmarked") as? [Repo] ?? []
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "bookmarked")
        }
    }

    private(set) lazy var reposRelay: BehaviorRelay<Set<Repo>> = {
        let relay = BehaviorRelay<Set<Repo>>(value: Set<Repo>())

        relay
            .subscribe(onNext: { [weak self] config in
                self?.repos = Array(config)
            }).disposed(by: disposeBag)

        UserDefaults.standard.rx.observe([Repo].self, reposKey)
            .compactMap { $0 }
            .map { Set($0) }
            .bind(to: relay)
            .disposed(by: disposeBag)

        return relay
    }()
}
