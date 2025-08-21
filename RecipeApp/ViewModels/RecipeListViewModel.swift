//
//  RecipeListViewModelProtocol.swift
//  RecipeApp
//
//  Created by TTHQ23-PANGWENHUEI on 19/08/2025.
//

import RxSwift
import RxRelay

protocol RecipeListViewModelProtocol {
    var recipes: Observable<[Recipe]> { get }
    var recipeTypes: Observable<[RecipeType]> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<Error> { get }
    
    func loadRecipes()
    func filterRecipes(by typeId: String?)
    func deleteRecipe(_ recipeId: String)
}

class RecipeListViewModel: RecipeListViewModelProtocol {
    private let recipeService: RecipeServiceProtocol
    private let recipeTypeService: RecipeTypeServiceProtocol
    private let disposeBag = DisposeBag()
    
    private let recipesRelay = BehaviorRelay<[Recipe]>(value: [])
    private let recipeTypesRelay = BehaviorRelay<[RecipeType]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<Error>()
    
    var recipes: Observable<[Recipe]> { recipesRelay.asObservable() }
    var recipeTypes: Observable<[RecipeType]> { recipeTypesRelay.asObservable() }
    var isLoading: Observable<Bool> { isLoadingRelay.asObservable() }
    var error: Observable<Error> { errorRelay.asObservable() }
    
    init(recipeService: RecipeServiceProtocol, recipeTypeService: RecipeTypeServiceProtocol) {
        self.recipeService = recipeService
        self.recipeTypeService = recipeTypeService
        
        loadRecipeTypes()
    }
    
    func loadRecipes() {
        isLoadingRelay.accept(true)
        
        recipeService.getAllRecipes()
            .subscribe(
                onNext: { [weak self] recipes in
                    self?.recipesRelay.accept(recipes)
                    self?.isLoadingRelay.accept(false)
                },
                onError: { [weak self] error in
                    self?.errorRelay.accept(error)
                    self?.isLoadingRelay.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func filterRecipes(by typeId: String?) {
        isLoadingRelay.accept(true)
        
        let observable = typeId != nil ? 
            recipeService.getRecipesByType(typeId!) : 
            recipeService.getAllRecipes()
        
        observable
            .subscribe(
                onNext: { [weak self] recipes in
                    self?.recipesRelay.accept(recipes)
                    self?.isLoadingRelay.accept(false)
                },
                onError: { [weak self] error in
                    self?.errorRelay.accept(error)
                    self?.isLoadingRelay.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func deleteRecipe(_ recipeId: String) {
        recipeService.deleteRecipe(recipeId)
            .subscribe(
                onNext: { [weak self] _ in
                    self?.loadRecipes()
                },
                onError: { [weak self] error in
                    self?.errorRelay.accept(error)
                }
            )
            .disposed(by: disposeBag)
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
