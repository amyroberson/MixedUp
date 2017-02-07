//
//  Drink+CoreDataClass.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

@objc(Drink)
public class Drink: NSManagedObject {
    static var entityName: String {
        return "Drink"
    }
    
    func toDictionary() -> [String: Any] {
        var ingredients: [[String: Any]] = []
        if let theIngredients = self.ingredients?.allObjects as? [Ingredient]{
            for ingredient in theIngredients {
                let dict = ingredient.toDictionary()
                ingredients.append(dict)
            }
        }
        
        var tools: [[String: Any]] = []
        if let theTools = self.tools?.allObjects as? [Tool]{
            for tool in theTools {
                let dict = tool.toDictionary()
                tools.append(dict)
            }
        }
        
        let keyValuePairs: [(String, Any?)] = [
            ("displayName",  self.displayName),
            ("isAlcoholic", self.isAlcoholic),
            ("id", self.id),
            ( "description", self.stringDescription),
            ("ingredients", ingredients),
            ("tools", tools),
            ("color", self.color?.toDictionary()),
            ("glass", self.glass?.toDictionary()),
            ("isIBAOfficial", self.isIBAOfficial),
            ("name", self.name)]
        
        var dict: [String: Any] = [:]
        
        for (key, optionalValue) in keyValuePairs {
            if let value = optionalValue {
                dict[key] = value
            }
        }
        return dict

    }
}
