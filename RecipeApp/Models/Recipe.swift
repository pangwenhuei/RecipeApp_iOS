//
//  Recipe.swift
//  RecipeApp
//
//  Created by TTHQ23-PANGWENHUEI on 19/08/2025.
//

import Foundation

struct Recipe {
    let id: String
    let title: String
    let recipeTypeId: String
    let imageURL: String?
    let ingredients: [String]
    let steps: [String]
    let createdDate: Date
    var updatedDate: Date
}
