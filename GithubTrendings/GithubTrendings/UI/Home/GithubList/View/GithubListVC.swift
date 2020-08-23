//
//  GithubListVC.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class GithubListVC: Controller<GithubListVM> {
    @IBOutlet private var segmentControl: UISegmentedControl!
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.registerCell(RepoTableViewCell.self)
            tableView.tableFooterView = UIView()
            tableView.estimatedRowHeight = 50
        }
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

        segmentControl.rx
            .selectedSegmentIndex
            .bind(to: vm.in.rx.segmentSwitched)
            .disposed(by: bag)
    }
}
