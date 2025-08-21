//
//  RecipeServiceProtocol.swift
//  RecipeApp
//
//  Created by TTHQ23-PANGWENHUEI on 19/08/2025.
//

import RxSwift
import CoreData

protocol RecipeServiceProtocol {
    func getAllRecipes() -> Observable<[Recipe]>
    func getRecipesByType(_ typeId: String) -> Observable<[Recipe]>
    func addRecipe(_ recipe: Recipe) -> Observable<Recipe>
    func updateRecipe(_ recipe: Recipe) -> Observable<Recipe>
    func deleteRecipe(_ recipeId: String) -> Observable<Void>
}

class RecipeService: RecipeServiceProtocol {
    private let context: NSManagedObjectContext
    private let disposeBag = DisposeBag()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAllRecipes() -> Observable<[Recipe]> {
        return Observable.create { observer in
            let request: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
            
            do {
                let entities = try self.context.fetch(request)
                let recipes = entities.map { $0.toRecipe() }
                observer.onNext(recipes)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func getRecipesByType(_ typeId: String) -> Observable<[Recipe]> {
        return Observable.create { observer in
            let request: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
            request.predicate = NSPredicate(format: "recipeTypeId == %@", typeId)
            request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
            
            do {
                let entities = try self.context.fetch(request)
                let recipes = entities.map { $0.toRecipe() }
                observer.onNext(recipes)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func addRecipe(_ recipe: Recipe) -> Observable<Recipe> {
        return Observable.create { observer in
            let entity = RecipeEntity(context: self.context)
            entity.id = recipe.id
            entity.title = recipe.title
            entity.recipeTypeId = recipe.recipeTypeId
            entity.imageURL = recipe.imageURL
            entity.ingredients = recipe.ingredients
            entity.steps = recipe.steps
            entity.createdDate = recipe.createdDate
            entity.updatedDate = recipe.updatedDate
            
            CoreDataManager.shared.saveContext()
            observer.onNext(recipe)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func updateRecipe(_ recipe: Recipe) -> Observable<Recipe> {
        return Observable.create { observer in
            let request: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", recipe.id)
            
            do {
                if let entity = try self.context.fetch(request).first {
                    entity.title = recipe.title
                    entity.recipeTypeId = recipe.recipeTypeId
                    entity.imageURL = recipe.imageURL
                    entity.ingredients = recipe.ingredients
                    entity.steps = recipe.steps
                    entity.updatedDate = recipe.updatedDate
                    
                    CoreDataManager.shared.saveContext()
                    observer.onNext(recipe)
                    observer.onCompleted()
                }
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func deleteRecipe(_ recipeId: String) -> Observable<Void> {
        return Observable.create { observer in
            let request: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", recipeId)
            
            do {
                if let entity = try self.context.fetch(request).first {
                    self.context.delete(entity)
                    CoreDataManager.shared.saveContext()
                    observer.onNext(())
                    observer.onCompleted()
                }
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
}
