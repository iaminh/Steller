//
//  SceneDelegate.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private lazy var appNavigationController = UINavigationController()
    private lazy var appRouter = Router(navigationController: self.appNavigationController)
    private lazy var homeModule = HomeModule(router: appRouter)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)

        window.rootViewController = homeModule.toPresentable()
        window.makeKeyAndVisible()

        self.window = window
    }
}

