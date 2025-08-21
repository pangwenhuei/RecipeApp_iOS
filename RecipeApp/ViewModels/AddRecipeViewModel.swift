//
//  AddRecipeViewModelProtocol.swift
//  RecipeApp
//
//  Created by TTHQ23-PANGWENHUEI on 19/08/2025.
//

import RxSwift
import RxRelay

protocol AddRecipeViewModelProtocol {
    var recipeTypes: Observable<[RecipeType]> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<Error> { get }
    var success: Observable<Recipe> { get }
    
    func addRecipe(title: String, typeId: String, imageURL: String?, ingredients: [String], steps: [String]) -> Observable<Recipe>
    func updateRecipe(_ recipe: Recipe, title: String, typeId: String, imageURL: String?, ingredients: [String], steps: [String]) -> Observable<Recipe>
}

class AddRecipeViewModel: AddRecipeViewModelProtocol {
    private let recipeService: RecipeServiceProtocol
    private let recipeTypeService: RecipeTypeServiceProtocol
    private let disposeBag = DisposeBag()
    
    private let recipeTypesRelay = BehaviorRelay<[RecipeType]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<Error>()
    private let successRelay = PublishRelay<Recipe>()
    
    var recipeTypes: Observable<[RecipeType]> { recipeTypesRelay.asObservable() }
    var isLoading: Observable<Bool> { isLoadingRelay.asObservable() }
    var error: Observable<Error> { errorRelay.asObservable() }
    var success: Observable<Recipe> { successRelay.asObservable() }
    
    init(recipeService: RecipeServiceProtocol, recipeTypeService: RecipeTypeServiceProtocol) {
        self.recipeService = recipeService
        self.recipeTypeService = recipeTypeService
        loadRecipeTypes()
    }
    
    func addRecipe(title: String, typeId: String, imageURL: String?, ingredients: [String], steps: [String]) -> Observable<Recipe> {
        isLoadingRelay.accept(true)

        let recipe = Recipe(
            id: UUID().uuidString,
            title: title,
            recipeTypeId: typeId,
            imageURL: imageURL,
            ingredients: ingredients,
            steps: steps,
            createdDate: Date(),
            updatedDate: Date()
        )

        return recipeService.addRecipe(recipe)
            .do(
                onNext: { [weak self] _ in
                    self?.isLoadingRelay.accept(false)
                    self?.successRelay.accept(recipe)
                },
                onError: { [weak self] error in
                    self?.isLoadingRelay.accept(false)
                    self?.errorRelay.accept(error)
                }
            )
    }
    
    func updateRecipe(_ recipe: Recipe, title: String, typeId: String, imageURL: String?, ingredients: [String], steps: [String]) -> Observable<Recipe> {
        isLoadingRelay.accept(true)

        let updatedRecipe = Recipe(
            id: recipe.id,
            title: title,
            recipeTypeId: typeId,
            imageURL: imageURL,
            ingredients: ingredients,
            steps: steps,
            createdDate: recipe.createdDate,
            updatedDate: Date()
        )

        return recipeService.updateRecipe(updatedRecipe)
            .do(
                onNext: { [weak self] _ in
                    self?.isLoadingRelay.accept(false)
                    self?.successRelay.accept(updatedRecipe)
                },
                onError: { [weak self] error in
                    self?.isLoadingRelay.accept(false)
                    self?.errorRelay.accept(error)
                }
            )
    }
    
    private func loadRecipeTypes() {
        recipeTypeService.getRecipeTypes()
            .subscribe(
                onNext: { [weak self] types in
                    self?.recipeTypesRelay.accept(types)
                },
                onError: { [weak self] error in
                    self?.errorRelay.accept(error)
                }
            )
            .disposed(by: disposeBag)
    }
}
