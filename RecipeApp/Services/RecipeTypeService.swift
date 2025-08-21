//
//  RecipeTypeServiceProtocol.swift
//  RecipeApp
//
//  Created by TTHQ23-PANGWENHUEI on 19/08/2025.
//

import RxSwift

protocol RecipeTypeServiceProtocol {
    func getRecipeTypes() -> Observable<[RecipeType]>
}

class RecipeTypeService: RecipeTypeServiceProtocol {
    func getRecipeTypes() -> Observable<[RecipeType]> {
        return Observable.create { observer in
            if let path = Bundle.main.path(forResource: "recipetypes", ofType: "json"),
               let data = NSData(contentsOfFile: path) {
                do {
                    let recipeTypes = try JSONDecoder().decode([RecipeType].self, from: data as Data)
                    observer.onNext(recipeTypes)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            } else {
                observer.onError(NSError(domain: "FileNotFound", code: 404, userInfo: nil))
            }
            
            return Disposables.create()
        }
    }
}
