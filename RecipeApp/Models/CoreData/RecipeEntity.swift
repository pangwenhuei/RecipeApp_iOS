//
//  RecipeEntity.swift
//  RecipeApp
//
//  Created by TTHQ23-PANGWENHUEI on 19/08/2025.
//


import CoreData

extension RecipeEntity {
    var ingredients: [String] {
        get {
            guard let data = ingredientsData as Data? else { return [] }
            return (try? JSONSerialization.jsonObject(with: data) as? [String]) ?? []
        }
        set {
            ingredientsData = (try? JSONSerialization.data(withJSONObject: newValue)) ?? Data()
        }
    }
    
    var steps: [String] {
        get {
            guard let data = stepsData as Data? else { return [] }
            return (try? JSONSerialization.jsonObject(with: data) as? [String]) ?? []
        }
        set {
            stepsData = (try? JSONSerialization.data(withJSONObject: newValue)) ?? Data()
        }
    }
    
    func toRecipe() -> Recipe {
        return Recipe(
            id: id ?? "",
            title: title ?? "",
            recipeTypeId: recipeTypeId ?? "",
            imageURL: imageURL,
            ingredients: ingredients,
            steps: steps,
            createdDate: createdDate ?? Date(),
            updatedDate: updatedDate ?? Date()
        )
    }
}
