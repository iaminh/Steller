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
import StanWoodCore

class GithubListVC: Controller<GithubListVM> {
    @IBOutlet private var segmentControl: UISegmentedControl! {
        didSet {
            segmentControl.removeAllSegments()
            vm.out.segments
                .enumerated()
                .forEach { index, item in segmentControl.insertSegment(withTitle: item, at: index, animated: false) }
            segmentControl.selectedSegmentIndex = 0
        }
    }
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.registerCell(RepoTableViewCell.self)
            tableView.tableFooterView = UIView()
            tableView.estimatedRowHeight = 50
        }
    }

    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.frame = CGRect(x: 0,
                                 y: 0,
                                 width: self.tableView.frame.size.width,
                                 height: 60)
        return indicator
    }()

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

        segmentControl.rx
            .selectedSegmentIndex
            .bind(to: vm.in.rx.segmentSwitched)
            .disposed(by: bag)

        let isNearBottomEdge = tableView.rx
            .contentOffset
            .map { [weak tableView = tableView] in
                guard let tableView = tableView else { return false }
                return GithubListVC.isNearTheBottomEdge(contentOffset: $0, tableView)
            }
            .filter { $0 }


        isNearBottomEdge
            .distinctUntilChanged()
            .subscribeOn(MainScheduler.instance)
            .bind { [unowned self] isNear in
                self.tableView?.tableFooterView = isNear ? self.indicatorView : nil
                if isNear {
                    self.indicatorView.startAnimating()
                } else {
                    self.indicatorView.stopAnimating()
                }
            }.disposed(by: bag)

    }

    private static let startLoadingOffset: CGFloat = 50.0
    private static func isNearTheBottomEdge(contentOffset: CGPoint, _ tableView: UITableView) -> Bool {
        return contentOffset.y + tableView.frame.size.height + startLoadingOffset > tableView.contentSize.height
    }
}

