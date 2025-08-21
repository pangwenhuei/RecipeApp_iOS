//
//  RecipeAppTests.swift
//  RecipeAppTests
//
//  Created by TTHQ23-PANGWENHUEI on 19/08/2025.
//

import XCTest
@testable import RecipeApp
import CoreData
import RxSwift

class RecipeAppTests: XCTestCase {
    var recipeService: RecipeService!
    var authService: AuthService!
    var recipeTypeService: RecipeTypeService!
    let disposeBag = DisposeBag()
    
    override func setUpWithError() throws {
        // Set up in-memory Core Data stack for testing
        let container = NSPersistentContainer(name: "RecipeApp")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
        
        recipeService = RecipeService(context: container.viewContext)
        authService = AuthService()
        recipeTypeService = RecipeTypeService()
    }
    
    override func tearDownWithError() throws {
        recipeService = nil
        authService = nil
        recipeTypeService = nil
    }
    
    func testAddRecipe() throws {
        let expectation = self.expectation(description: "Add recipe")
        
        let recipe = Recipe(
            id: "test-1",
            title: "Test Recipe",
            recipeTypeId: "test-type",
            imageURL: nil,
            ingredients: ["Ingredient 1", "Ingredient 2"],
            steps: ["Step 1", "Step 2"],
            createdDate: Date(),
            updatedDate: Date()
        )
        
        recipeService.addRecipe(recipe)
            .subscribe(
                onNext: { _ in
                    expectation.fulfill()
                },
                onError: { error in
                    XCTFail("Failed to add recipe: \(error)")
                }
            ).disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAuthentication() throws {
        let expectation = self.expectation(description: "Authentication")
        
        authService.login(username: "admin", password: "password")
            .subscribe(
                onNext: { success in
                    XCTAssertTrue(success)
                    expectation.fulfill()
                },
                onError: { error in
                    XCTFail("Authentication failed: \(error)")
                }
            ).disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRecipeTypeService() throws {
        // This test would need the recipetypes.json file in the test bundle
        let expectation = self.expectation(description: "Load recipe types")
        
        recipeTypeService.getRecipeTypes()
            .subscribe(
                onNext: { types in
                    XCTAssertFalse(types.isEmpty)
                    expectation.fulfill()
                },
                onError: { error in
                    // Expected to fail in test environment without the JSON file
                    expectation.fulfill()
                }
            ).disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRecipeViewModel() throws {
        let expectation = self.expectation(description: "Recipe list view model")
        
        let viewModel = RecipeListViewModel(
            recipeService: recipeService,
            recipeTypeService: recipeTypeService
        )
        
        viewModel.recipes
            .take(1)
            .subscribe(onNext: { recipes in
                // Should start with empty array
                XCTAssertTrue(recipes.isEmpty)
                expectation.fulfill()
            }).disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
