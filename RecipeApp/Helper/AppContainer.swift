//
//  AppContainer.swift
//  RecipeApp
//
//  Created by TTHQ23-PANGWENHUEI on 19/08/2025.
//

// Dependency Injection Container

import Swinject
import CoreData

class AppContainer {
    static let shared = AppContainer()
    let container = Container()
    
    private init() {
        setupDependencies()
    }
    
    private func setupDependencies() {
        // Core Data
        container.register(NSManagedObjectContext.self) { _ in
            return CoreDataManager.shared.context
        }.inObjectScope(.container)
        
        // Services
        container.register(RecipeServiceProtocol.self) { resolver in
            return RecipeService(context: resolver.resolve(NSManagedObjectContext.self)!)
        }.inObjectScope(.container)
        
        container.register(AuthServiceProtocol.self) { _ in
            return AuthService()
        }.inObjectScope(.container)
        
        container.register(RecipeTypeServiceProtocol.self) { _ in
            return RecipeTypeService()
        }.inObjectScope(.container)
        
        // ViewModels
        container.register(RecipeListViewModelProtocol.self) { resolver in
            return RecipeListViewModel(
                recipeService: resolver.resolve(RecipeServiceProtocol.self)!,
                recipeTypeService: resolver.resolve(RecipeTypeServiceProtocol.self)!
            )
        }
        
        container.register(AddRecipeViewModelProtocol.self) { resolver in
            return AddRecipeViewModel(
                recipeService: resolver.resolve(RecipeServiceProtocol.self)!,
                recipeTypeService: resolver.resolve(RecipeTypeServiceProtocol.self)!
            )
        }
    }
}
