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
    private var repos: [Repo] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "bookmarked") else {
                return []
            }
            return (try? CustomDecoder().decode([Repo].self, from: data)) ?? []
        }
        set {
            guard let encoded = try? CustomEncoder().encode(newValue) else {
                return
            }
            UserDefaults.standard.setValue(encoded, forKey: "bookmarked")
        }
    }

    private(set) lazy var reposRelay: BehaviorRelay<Set<Repo>> = {
        let relay = BehaviorRelay<Set<Repo>>(value: Set(self.repos))

        relay
            .subscribe(onNext: { [weak self] config in
                self?.repos = Array(config)
            }).disposed(by: disposeBag)

        UserDefaults.standard.rx.observe([Repo].self, "bookmarked")
            .compactMap { $0 }
            .map { Set($0) }
            .bind(to: relay)
            .disposed(by: disposeBag)

        return relay
    }()
}
