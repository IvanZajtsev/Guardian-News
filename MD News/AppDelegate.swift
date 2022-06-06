//
//  AppDelegate.swift
//  MD News
//
//  Created by Иван Зайцев on 29.03.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow()
        
        let tabBarController = UITabBarController()
        let thirdVC = FavoritesViewController()
        
        thirdVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 777)
        
        let startVC = NewsViewController()
        
        let navigationController = UINavigationController(rootViewController: startVC)
        navigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 666)
        
        tabBarController.viewControllers = [navigationController, thirdVC]
        
        // window.rootViewController = navigationController
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        self.window = window
        
        return true
    }

    

}

