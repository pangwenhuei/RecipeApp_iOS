//
//  MainTabBarController.swift
//  RecipeApp
//
//  Created by TTHQ23-PANGWENHUEI on 20/08/2025.
//

import UIKit


class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let recipeListVC = RecipeListViewController()
        let navController = UINavigationController(rootViewController: recipeListVC)
        navController.tabBarItem = UITabBarItem(title: "Recipes", image: UIImage(systemName: "list.dash"), tag: 0)
        
        viewControllers = [navController]
    }
}
