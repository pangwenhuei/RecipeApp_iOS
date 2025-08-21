//
//  RecipeAppUITests.swift
//  RecipeAppUITests
//
//  Created by TTHQ23-PANGWENHUEI on 19/08/2025.
//

import XCTest

class RecipeAppUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testLoginFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Perform login
        if app.textFields["Username (admin)"].exists {
            app.textFields["Username (admin)"].tap()
            app.textFields["Username (admin)"].typeText("admin")
        }
        
        if app.textFields["Password (password)"].exists {
            app.textFields["Password (password)"].tap()
            app.textFields["Password (password)"].typeText("password")
        }
        
        if app.buttons["Login"].exists {
            app.buttons["Login"].tap()
        }
        
        // Check if main screen appears
        let recipesTitle = app.navigationBars["Recipes"]
        XCTAssertTrue(recipesTitle.waitForExistence(timeout: 5))
    }
    
    func testAddRecipeFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Login first
        loginIfNeeded(app: app)
        
        // Tap add button
        let addButton = app.navigationBars["Recipes"].buttons["Add"]
        addButton.tap()
        
        // Check if add recipe screen appears
        let addRecipeTitle = app.navigationBars["Add Recipe"]
        XCTAssertTrue(addRecipeTitle.waitForExistence(timeout: 2))
        
        // Fill in recipe details
        let titleField = app.textFields["Enter recipe title"]
        titleField.tap()
        titleField.typeText("Test Recipe")
        
        // Cancel and go back
        let cancelButton = app.navigationBars["Add Recipe"].buttons["Cancel"]
        cancelButton.tap()
        
        // Should be back to recipe list
        let recipesTitle = app.navigationBars["Recipes"]
        XCTAssertTrue(recipesTitle.exists)
    }
    
    private func loginIfNeeded(app: XCUIApplication) {
        if app.textFields["Username (admin)"].exists {
            app.textFields["Username (admin)"].tap()
            app.textFields["Username (admin)"].typeText("admin")
            
            app.secureTextFields["Password (password)"].tap()
            app.secureTextFields["Password (password)"].typeText("password")
            
            app.buttons["Login"].tap()
            
            // Wait for recipes screen
            _ = app.navigationBars["Recipes"].waitForExistence(timeout: 5)
        }
    }
}
