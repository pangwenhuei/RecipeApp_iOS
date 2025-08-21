//
//  SceneDelegate.swift
//  RecipeApp
//
//  Created by TTHQ23-PANGWENHUEI on 19/08/2025.
//

import UIKit
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let disposeBag = DisposeBag()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let authService = AppContainer.shared.container.resolve(AuthServiceProtocol.self)!
        
        // Check if user is logged in
        authService.isLoggedIn
            .take(1)
            .subscribe(onNext: { [weak self] isLoggedIn in
                DispatchQueue.main.async {
                    if isLoggedIn {
                        let tabBarController = MainTabBarController()
                        self?.window?.rootViewController = tabBarController
                    } else {
                        let loginViewController = LoginViewController()
                        self?.window?.rootViewController = loginViewController
                    }
                    
                    self?.window?.makeKeyAndVisible()
                }
            })
            .disposed(by: disposeBag)
        
        // Pre-populate sample data
        populateSampleData()
    }
    
    private func populateSampleData() {
        let recipeService = AppContainer.shared.container.resolve(RecipeServiceProtocol.self)!
        
        // Sample recipes
        let sampleRecipes = [
            Recipe(
                id: "1",
                title: "Classic Spaghetti Carbonara",
                recipeTypeId: "italian",
                imageURL: "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg",
                ingredients: [
                    "400g spaghetti",
                    "200g pancetta or guanciale",
                    "4 large eggs",
                    "100g Pecorino Romano cheese",
                    "Black pepper",
                    "Salt"
                ],
                steps: [
                    "Cook spaghetti according to package instructions",
                    "Fry pancetta until crispy",
                    "Beat eggs with cheese and pepper",
                    "Combine hot pasta with pancetta",
                    "Add egg mixture and toss quickly",
                    "Serve immediately"
                ],
                createdDate: Date(),
                updatedDate: Date()
            ),
            Recipe(
                id: "2",
                title: "Chocolate Chip Cookies",
                recipeTypeId: "dessert",
                imageURL: "https://sallysbakingaddiction.com/wp-content/uploads/2013/05/classic-chocolate-chip-cookies.jpg",
                ingredients: [
                    "2¼ cups all-purpose flour",
                    "1 tsp baking soda",
                    "1 tsp salt",
                    "1 cup butter, softened",
                    "¾ cup granulated sugar",
                    "¾ cup brown sugar",
                    "2 large eggs",
                    "2 tsp vanilla extract",
                    "2 cups chocolate chips"
                ],
                steps: [
                    "Preheat oven to 375°F",
                    "Mix flour, baking soda, and salt in bowl",
                    "Beat butter and sugars until creamy",
                    "Beat in eggs and vanilla",
                    "Gradually blend in flour mixture",
                    "Stir in chocolate chips",
                    "Drop rounded tablespoons onto baking sheet",
                    "Bake 9-11 minutes until golden brown"
                ],
                createdDate: Date(),
                updatedDate: Date()
            )
        ]
        
        // Add sample recipes if not already present
        recipeService.getAllRecipes()
            .take(1)
            .subscribe(onNext: { existingRecipes in
                if existingRecipes.isEmpty {
                    sampleRecipes.forEach { recipe in
                        recipeService.addRecipe(recipe)
                            .subscribe()
                            .disposed(by: self.disposeBag)
                    }
                }
            })
            .disposed(by: disposeBag)
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

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

