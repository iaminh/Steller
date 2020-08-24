//
//  BaseViewController.swift
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {
    let showLoading = BehaviorSubject<Bool>(value: false)
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        showLoading
            .subscribeOn(MainScheduler.instance)
            .bind { [weak self] loading in
                if loading {
                    self?.showActivityIndicator()
                } else {
                    self?.hideActivityIndicator()
                }
            }.disposed(by: bag)

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

private let overlayViewTag = 999
private let activityIndicatorTag = 1_000

private extension UIViewController {
    func showActivityIndicator() {
        setActivityIndicator()
    }

    func hideActivityIndicator() {
        removeActivityIndicator()
    }

    func setActivityIndicator() {
        guard !isDisplayingActivityIndicatorOverlay() else { return }
        guard let parentViewForOverlay = view else { return }

        //configure overlay
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.white
        overlay.alpha = 0.6
        overlay.tag = overlayViewTag

        //configure activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.tag = activityIndicatorTag
        activityIndicator.color = .black

        //add subviews
        overlay.addSubview(activityIndicator)
        parentViewForOverlay.addSubview(overlay)

        //add overlay constraints
        overlay.heightAnchor.constraint(equalTo: parentViewForOverlay.heightAnchor).isActive = true
        overlay.widthAnchor.constraint(equalTo: parentViewForOverlay.widthAnchor).isActive = true

        //add indicator constraints
        activityIndicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor).isActive = true

        //animate indicator
        activityIndicator.startAnimating()
    }

    func removeActivityIndicator() {
        let activityIndicator = getActivityIndicator()

        if let overlayView = getOverlayView() {
            let animations = {
                overlayView.alpha = 0.0
                activityIndicator?.stopAnimating()
            }
            UIView.animate(withDuration: 0.2, animations: animations) { _ in
                activityIndicator?.removeFromSuperview()
                overlayView.removeFromSuperview()
            }
        }
    }

    func isDisplayingActivityIndicatorOverlay() -> Bool {
        if getActivityIndicator() != nil && getOverlayView() != nil {
            return true
        }
        return false
    }

    func getActivityIndicator() -> UIActivityIndicatorView? {
        return (view.viewWithTag(activityIndicatorTag)) as? UIActivityIndicatorView
    }

    func getOverlayView() -> UIView? {
        return view.viewWithTag(overlayViewTag)
    }
}
