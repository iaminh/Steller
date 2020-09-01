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
            tableView.tableFooterView = indicatorView
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
            .map { [weak tableView = tableView] offset -> Bool in
                guard let tableView = tableView else { return false }
                return GithubListVC.isNearTheBottomEdge(contentOffset: offset, tableView)
            }
            .distinctUntilChanged()

        isNearBottomEdge
            .filter { $0 }
            .map { _ in Void() }
            .bind(to: vm.in.rx.loadNext)
            .disposed(by: bag)

        isNearBottomEdge
            .subscribeOn(MainScheduler.instance)
            .bind { [unowned self] isNear in
                if isNear {
                    self.indicatorView.startAnimating()
                } else {
                    self.indicatorView.stopAnimating()
                }
            }.disposed(by: bag)
    }

    private static let startLoadingOffset: CGFloat = 20.0
    private static func isNearTheBottomEdge(contentOffset: CGPoint, _ tableView: UITableView) -> Bool {
        return contentOffset.y + tableView.frame.size.height + startLoadingOffset > tableView.contentSize.height
    }
}

