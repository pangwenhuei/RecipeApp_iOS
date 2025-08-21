//
//  MyResponse.swift
//  RecipeApp
//
//  Created by TTHQ23-PANGWENHUEI on 20/08/2025.
//

struct LoginResponse: Decodable {
    let success: Bool
    let message: String
    let token: String
}
