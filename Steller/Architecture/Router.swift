//
//  Router.swift
//
//  Created by Chu Anh Minh on 2/25/19.

import UIKit

class Router: NSObject, Presentable, UINavigationControllerDelegate {
    private var completions: [UIViewController : () -> Void]

    var rootViewController: UIViewController? {
        return navigationController.viewControllers.first
    }

    var hasRootController: Bool {
        return rootViewController != nil
    }

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
        self.completions = [:]
        super.init()
        self.navigationController.delegate = self
    }
    
    // MARK: Presentable

    func toPresentable() -> UIViewController {
        return navigationController
    }

    deinit {
        if navigationController.presentedViewController != nil {
            dismiss()
        }
    }

    func present(_ presentable: Presentable, animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController.present(presentable.toPresentable(), animated: animated, completion: completion)
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController.dismiss(animated: animated, completion: completion)
    }

    func dismiss(module: Module, animated: Bool = true, completion: (() -> Void)? = nil) {
        if navigationController.presentedViewController == module.toPresentable() {
            dismiss(animated: animated, completion: completion)
        }
    }

    func push(_ presentable: Presentable,
              animated: Bool = true,
              completion: (() -> Void)? = nil) {
        let controller = presentable.toPresentable()

        guard controller is UINavigationController == false else {
            return
        }

        if let completion = completion {
            completions[controller] = completion
        }

        navigationController.pushViewController(controller, animated: animated)
    }

    func pop(animated: Bool = true) {
        if let controller = navigationController.popViewController(animated: animated) {
            runCompletion(for: controller)
        }
    }

    func setRoot(_ presentable: Presentable, hideBar: Bool = false, completion: (() -> Void)? = nil) {
        // Call all completions so all coordinators can be deallocated
        for controller in navigationController.viewControllers {
            runCompletion(for: controller)
        }

        let controller = presentable.toPresentable()

        if let vc = controller as? UINavigationController {
            navigationController.setViewControllers(vc.viewControllers, animated: false)
            if let completion = completion {
                vc.viewControllers.forEach { completions[$0] = completion }
            }
        } else {
            navigationController.setViewControllers([controller], animated: false)
            if let completion = completion {
                completions[controller] = completion
            }
        }
        navigationController.isNavigationBarHidden = hideBar
    }

    func popToRoot(animated: Bool) {
        if let controllers = navigationController.popToRootViewController(animated: animated) {
            controllers.forEach { runCompletion(for: $0) }
        }
    }

    func popTo(_ presentable: Presentable, animated: Bool = true) {
        if let controllers = navigationController.popToViewController(presentable.toPresentable(), animated: animated) {
            controllers.forEach { runCompletion(for: $0) }
        }
    }

    func controllerFromStack<T: UIViewController>(withKind kind: T.Type) -> T? {
        return navigationController.viewControllers.first { $0.isKind(of: kind) } as? T
    }

    private func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else { return }
        completion()
        completions.removeValue(forKey: controller)
    }

    // MARK: UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // Ensure the view controller is popping
        guard let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(poppedViewController) else {
                return
        }

        runCompletion(for: poppedViewController)
    }

    func hideBar(_ hide: Bool) {
        navigationController.isNavigationBarHidden = hide
    }
}
