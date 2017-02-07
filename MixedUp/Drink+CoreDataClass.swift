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
    
    func toDictionary() -> [String: Any?] {
        var ingredients: [[String: Any?]] = []
        if let theIngredients = self.ingredients?.allObjects as? [Ingredient]{
            for ingredient in theIngredients {
                let dict = ingredient.toDictionary()
                ingredients.append(dict)
            }
        }
        
        var tools: [[String: Any?]] = []
        if let theTools = self.tools?.allObjects as? [Tool]{
            for tool in theTools {
                let dict = tool.toDictionary()
                tools.append(dict)
            }
        }
        
        let dictionary: [String: Any?] = [
            "name": self.name,
            "displayName": self.displayName,
            "isAlcoholic": self.isAlcoholic,
            "isIBAOfficial" : self.isIBAOfficial,
            "description" : self.stringDescription,
            "id" : self.id,
            "ingredients": ingredients,
            "tools": tools,
            "color" : self.color?.toDictionary(),
            "glass" : self.glass?.toDictionary()
            ]
        return dictionary
    }
}
