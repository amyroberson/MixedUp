//
//  Util.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData


enum ResourceResult<A> {
    case success(A)
    case sucess(Bool)
    case failure(Errors)
    case fail(NSError)
    
    var successValue: A? {
        switch self {
        case .success(let value):
            return value
        case .sucess, .fail, .failure:
            return nil
        }
    }
}

enum Errors: Swift.Error{
    case http(HTTPURLResponse)
    case system(Swift.Error)
    case resource(Util.Error)
    case invalidJSONData
    case inValidParameter
    case failedToSave
    
}

struct Util {
    internal enum Error: Swift.Error {
        case invalidJSONData
        
    }
    
    
    
    static func searchDrinks(allDrinks:[Drink], searchText: String) -> [Drink]{
        var returning: Set<Drink> = []
        for drink in allDrinks{
            for ingredient in drink.ingredients!{
                if ((ingredient as! Ingredient).displayName?.lowercased().contains(searchText))! {
                    returning.insert(drink)
                    break
                } else if returning.contains(drink){
                    returning.remove(drink)
                }
            }
            if (drink.displayName?.lowercased().contains(searchText))!{
                returning.insert(drink)
            }
        }
        return Array(returning)
    }
    
    static func getIsAlcoholic(ingredients: [Ingredient]) -> Bool{
        for ingredient in ingredients{
            if ingredient.isAlcoholic{
                return true
            }
        }
        return false
    }
    
    static func getMissingIngredients(_ userInventory: [Ingredient], _ drinkIngredients: [Ingredient]) -> [Ingredient]{
        var missingIngredients: [Ingredient] = []
        for ingredient in drinkIngredients{
            if !userInventory.contains(ingredient){
                missingIngredients.append(ingredient)
            }
        }
        return missingIngredients
        
    }
}

