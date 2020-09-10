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
    @IBOutlet private var dayTableView: UITableView! {
        didSet {
            configTableView(tableView: dayTableView)
        }
    }
    @IBOutlet private var weekTableView: UITableView! {
        didSet {
            configTableView(tableView: weekTableView)
        }
    }
    @IBOutlet private var monthTableView: UITableView! {
        didSet {
            configTableView(tableView: monthTableView)
        }
    }
    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.frame = CGRect(x: 0,
                                 y: 0,
                                 width: self.dayTableView.frame.size.width,
                                 height: 60)
        return indicator
    }()

    private func configTableView(tableView: UITableView) {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerCell(RepoTableViewCell.self)
        tableView.tableFooterView = indicatorView
        tableView.estimatedRowHeight = 50
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = vm.out.title
    }

    override func bindToVM() {
        super.bindToVM()

        Observable.merge(monthTableView.rx.itemSelected.asObservable(),
                         dayTableView.rx.itemSelected.asObservable(),
                         weekTableView.rx.itemSelected.asObservable())
            .map { $0.row }
            .bind(to: vm.in.rx.selected)
            .disposed(by: bag)

        let isNearBottomEdge = Observable.merge(monthTableView.rx.contentOffset.asObservable(),
                                                dayTableView.rx.contentOffset.asObservable(),
                                                weekTableView.rx.contentOffset.asObservable())
            .withLatestFrom(segmentControl.rx.selectedSegmentIndex) { ($0, $1) }
            .map { [weak self] (offset, index) -> Bool in
                guard let self = self else { return false }
                switch index {
                case 0:
                    return GithubListVC.isNearTheBottomEdge(contentOffset: offset, self.dayTableView)
                case 1:
                    return GithubListVC.isNearTheBottomEdge(contentOffset: offset, self.weekTableView)
                case 2:
                    return GithubListVC.isNearTheBottomEdge(contentOffset: offset, self.monthTableView)
                default:
                    fatalError("Index out of bounds")
                }
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

    private func bindCells() {
        vm.out
            .rx
            .todayCells
            .drive(dayTableView.rx.items(
                cellIdentifier: RepoTableViewCell.autoReuseIdentifier,
                cellType: RepoTableViewCell.self)) { _ , model, cell in cell.config(with: model) }
            .disposed(by: bag)

        vm.out
            .rx
            .lastWeekCells
            .drive(weekTableView.rx.items(
                cellIdentifier: RepoTableViewCell.autoReuseIdentifier,
                cellType: RepoTableViewCell.self)) { _ , model, cell in cell.config(with: model) }
            .disposed(by: bag)

        vm.out
            .rx
            .lastMonthcells
            .drive(monthTableView.rx.items(
                cellIdentifier: RepoTableViewCell.autoReuseIdentifier,
                cellType: RepoTableViewCell.self)) { _ , model, cell in cell.config(with: model) }
            .disposed(by: bag)
    }

    private func bindSegment() {
        segmentControl.rx
            .selectedSegmentIndex
            .bind(to: vm.in.rx.segmentSwitched)
            .disposed(by: bag)

        segmentControl.rx.selectedSegmentIndex
            .map { $0 != 0 }
            .bind(to: dayTableView.rx.isHidden)
            .disposed(by: bag)

        segmentControl.rx.selectedSegmentIndex
            .map { $0 != 1 }
            .bind(to: weekTableView.rx.isHidden)
            .disposed(by: bag)

        segmentControl.rx.selectedSegmentIndex
            .map { $0 != 2 }
            .bind(to: monthTableView.rx.isHidden)
            .disposed(by: bag)
    }

    private static let startLoadingOffset: CGFloat = 20.0
    private static func isNearTheBottomEdge(contentOffset: CGPoint, _ tableView: UITableView) -> Bool {
        return contentOffset.y + tableView.frame.size.height + startLoadingOffset > tableView.contentSize.height
    }
}

