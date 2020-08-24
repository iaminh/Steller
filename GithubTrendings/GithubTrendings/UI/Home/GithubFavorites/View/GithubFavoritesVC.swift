//
//  GithubFavoritesVC.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class GithubFavoritesVC: Controller<GithubFavoritesVM> {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.registerCell(RepoTableViewCell.self)
            tableView.tableFooterView = UIView()
            tableView.estimatedRowHeight = 50
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = vm.out.title
    }

    override func bindToVM() {
        super.bindToVM()

        vm.out
            .rx
            .cells
            .drive(tableView.rx.items(
                cellIdentifier: RepoTableViewCell.autoReuseIdentifier,
                cellType: RepoTableViewCell.self)) { _ , model, cell in cell.config(with: model) }
            .disposed(by: bag)

        tableView.rx
            .itemSelected
            .map { $0.row }
            .bind(to: vm.in.rx.selected)
            .disposed(by: bag)
    }
}
