//
//  User+CoreDataClass.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    static var entityName: String {
        return "User"
    }
    
    func toDictionary() -> [String:Any]{
        var ingredients: [[String: Any]] = []
        if let theIngredients = self.inventory?.allObjects as? [Ingredient]{
            for ingredient in theIngredients {
                let dict = ingredient.toDictionary()
                ingredients.append(dict)
            }
        }
        var drinks: [[String: Any]] = []
        if let theDrinks = self.favoriteDrinks?.allObjects as? [Drink]{
            for drink in theDrinks {
                let dict = drink.toDictionary()
                drinks.append(dict)
            }
        }
        
        let keyValuePairs: [(String, Any?)] = [
            ("id", self.id),
            ("inventory", ingredients),
            ("barsManaged", []),
            ("favoriteDrinks", drinks),
            ("email", self.email)
        ]
        
        var dict: [String: Any] = [:]
        
        for (key, optionalValue) in keyValuePairs {
            if let value = optionalValue {
                dict[key] = value
            }
        }
        return dict
        ///update to properly inclue bars
    }
}
