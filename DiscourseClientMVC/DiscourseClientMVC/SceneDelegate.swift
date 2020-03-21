//
//  SceneDelegate.swift
//  DiscourseClientMVC
//
//  Created by Ricardo González Pacheco on 17/03/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let topicsVC = TopicsViewController()
        let categoriesVC = CategoriesViewController()
        let usersVC = UsersViewController()
        
        let navigationTopicsVC = UINavigationController(rootViewController: topicsVC)
        let navigationCategoriesVC = UINavigationController(rootViewController: categoriesVC)
        let navigationUsersVC = UINavigationController(rootViewController: usersVC)
        
        navigationTopicsVC.tabBarItem = UITabBarItem(title: "Topics", image: UIImage(systemName: "list.bullet"), tag: 0)
        navigationCategoriesVC.tabBarItem = UITabBarItem(title: "Categories", image: UIImage(systemName: "tag"), tag: 1)
        navigationUsersVC.tabBarItem = UITabBarItem(title: "Users", image: UIImage(systemName: "person"), tag: 2)

        let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13.0)]
        navigationTopicsVC.tabBarItem.setTitleTextAttributes(fontAttributes, for: .normal)
        navigationCategoriesVC.tabBarItem.setTitleTextAttributes(fontAttributes, for: .normal)
        navigationUsersVC.tabBarItem.setTitleTextAttributes(fontAttributes, for: .normal)

        UINavigationBar.appearance().overrideUserInterfaceStyle = .dark
        UINavigationBar.appearance().backgroundColor = UIColor.black
        UINavigationBar.appearance().tintColor = UIColor.systemBlue
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [navigationTopicsVC, navigationCategoriesVC, navigationUsersVC]

        tabBarController.tabBar.barStyle = .black
        tabBarController.tabBar.isTranslucent = true
        tabBarController.tabBar.barTintColor = UIColor.black
        tabBarController.tabBar.tintColor = UIColor.systemBlue
                

        window = UIWindow.init(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

