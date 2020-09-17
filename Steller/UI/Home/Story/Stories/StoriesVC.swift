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

class StoriesVC: Controller<StoriesVM> {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.registerCell(StoryCVCell.self)
            collectionView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = vm.out.title
    }

    override func bindToVM() {
        super.bindToVM()
        bindCells()
    }

    private func bindCells() {
        vm.out
            .rx
            .cells
            .drive(collectionView.rx.items(
                cellIdentifier: StoryCVCell.autoReuseIdentifier,
                cellType: StoryCVCell.self)) { _ , model, cell in cell.config(with: model) }
            .disposed(by: bag)

        collectionView.rx
            .itemSelected
            .map { $0.row }
            .bind(to: vm.in.rx.selected)
            .disposed(by: bag)
    }
}

extension StoriesVC: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (collectionView.bounds.width - 30) / 2, height: 300)
    }
}
