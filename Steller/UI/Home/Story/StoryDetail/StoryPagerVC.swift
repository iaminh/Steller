//
//  StoryPagerVC.swift
//  Steller
//
//  Created by Chu Anh Minh on 9/17/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

//
//  StoryPagerVC.swift
//  Steller
//
//  Created by Chu Anh Minh on 9/17/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import UIKit

class StoryPagerVC: UIViewController {
    private let orderedViewControllers: [UIViewController]
    private let pagerVC = UIPageViewController(transitionStyle: .scroll,
                                               navigationOrientation: .horizontal,
                                               options: nil)

    init(vcs: [UIViewController]) {
        self.orderedViewControllers = vcs
        super.init(nibName: NSStringFromClass(type(of: self))
            .components(separatedBy: ".").last, bundle: nil)

        pagerVC.dataSource = self
        if let first = orderedViewControllers.first {
            pagerVC.setViewControllers([first], direction: .forward, animated: false, completion: nil)
        }

        embedPager()
    }

    private func embedPager() {
        self.addChild(pagerVC)
        pagerVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pagerVC.view)

        NSLayoutConstraint.activate([
            pagerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            pagerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            pagerVC.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            pagerVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StoryPagerVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
                return nil
            }

            let previousIndex = viewControllerIndex - 1

            // User is on the first view controller and swiped left to loop to
            // the last view controller.
            guard previousIndex >= 0 else {
                return orderedViewControllers.last
            }

            guard orderedViewControllers.count > previousIndex else {
                return nil
            }

            return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
                return nil
            }

            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = orderedViewControllers.count

            // User is on the last view controller and swiped right to loop to
            // the first view controller.
            guard orderedViewControllersCount != nextIndex else {
                return orderedViewControllers.first
            }

            guard orderedViewControllersCount > nextIndex else {
                return nil
            }

            return orderedViewControllers[nextIndex]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
}
