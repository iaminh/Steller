//
//  Module.swift
//
//  Created by Chu Anh Minh on 2/23/19.
//

import UIKit
import RxSwift
import RxCocoa

class Module: NSObject, Presentable {
    let router: Router
    let bag = DisposeBag()
    private var childModules: [Module] = []

    let alertSubject = PublishSubject<AlertConfig>()

    private func configObservers() {
        alertSubject
            .subscribeOn(MainScheduler.instance)
            .bind { [weak self] alertConfig in
                switch alertConfig.style {
                case .systemAlert, .actionSheet:
                    self?.showSystemAlert(with: alertConfig)
                }
            }.disposed(by: bag)
    }
    
    init(router: Router) {
        self.router = router
        super.init()
        
        configObservers()
    }

    func toPresentable() -> UIViewController {
        fatalError("Override")
    }

    func addChild(_ module: Module) {
        childModules.append(module)
    }

    func removeChild(_ module: Module?) {
        if let module = module, let index = childModules.firstIndex(of: module) {
            childModules.remove(at: index)
        }
    }

    func pushChild(module: Module, animated: Bool, onRemove: (() -> Void)? = nil) {
        addChild(module)

        router.push(module, animated: animated) { [weak self, weak module] in
            guard let self = self else { return }
            onRemove?()
            self.removeChild(module)
        }
    }

    func dismissChild(module: Module, animated: Bool) {
        module.toPresentable().presentingViewController?.dismiss(animated: animated, completion: nil)
        removeChild(module)
    }

    func dismissChildOf<T: Module>(type: T.Type, animated: Bool) {
        for childModule in childModules where childModule is T {
            dismissChild(module: childModule, animated: animated)
        }
    }
        
    private func showSystemAlert(with alertConfig: AlertConfig) {
        let style: UIAlertController.Style

        switch alertConfig.style {
        case .actionSheet:
            style = .actionSheet
        default:
            style = .alert
        }

        let alertVC = UIAlertController(title: alertConfig.title, message: alertConfig.message, preferredStyle: style)

        if #available(iOS 13.0, *) {
            alertVC.overrideUserInterfaceStyle = .light
        }

        alertConfig.actions.map { action in
            switch action.style {
            case .default, .yellow:
                return UIAlertAction(title: action.title, style: .default) { _ in
                    action.handler?()
                }
            case .cancel:
                return UIAlertAction(title: action.title, style: .destructive) { _ in
                    action.handler?()
                }
            }
        }.forEach { alertVC.addAction($0) }

        router.present(alertVC, animated: true, completion: nil)
    }
}
