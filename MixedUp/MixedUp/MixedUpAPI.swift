//
//  MixedUpAPI.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

internal func debugPrintSingleDrink(drink: Drink) {
    print(drink.displayName!)
    for ingredient in (drink.ingredients?.allObjects)!{
        print("  \((ingredient as! Ingredient).displayName!)")
    }
}

func debugPrintDrinks(drinks: [Drink]) {
    for d in drinks {
        debugPrintSingleDrink(drink: d)
    }
}

class MixedUpAPI {
    enum Error: Swift.Error {
        case invalidJSONData
    }
    
    static let userKey = "user"
    static let usersKey = "users"
    static let idKey = "id"
    static let userTypeKey = "User"
    static let emailKey = "email"
    static let inventoryKey = "inventory"
    static let favoriteDrinksKey = "favoriteDrinks"
    static let barsManagedKey = "barsManaged"
    static let drinksKey = "drinks"
    static let menuKey = "menu"
    static let specialtiesKey = "specialties"
    static let displayNameKey = "displayName"
    static let nameKey = "name"
    static let isAlcoholicKey = "isAlcoholic"
    static let isIBAOficialKey = "isIBAOfficial"
    static let drinkTypeKey = "Drink"
    static let descriptionKey = "description"
    static let ingredientsKey = "ingredients"
    static let toolsKey = "tools"
    static let colorKey = "color"
    static let glassKey = "glass"
    static let ingredientTypesKey = "ingredienttypes"
    static let ingredientTypeKey = "IngredientType"
    static let glassTypeKey = "Glass"
    static let toolTypeKey = "Tool"
    static let redKey = "red"
    static let greenKey = "green"
    static let blueKey = "blue"
    static let alphaKey = "alpha"
    static let colorTypeKey = "Color"
    static let ingredientKey = "ingredient"
    static let ingredientEntityTypeKey = "Ingredient"
    static let ingredienttypeKey = "ingredientType"
    static let typeKey = "type"
    
    static func jsonToDictionary(_ data: Data)throws -> [String:Any] {
        guard let jsonObject: [String: Any] = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw Error.invalidJSONData
        }
        return jsonObject
    }
    
    static func dictionaryToJson(_ dictionary: [String:Any])throws -> Data {
        let jsonRepresentation = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        return jsonRepresentation
    }
    
    static func getUsersFromDictionary(_ dictionary: [String: Any], inContext context: NSManagedObjectContext) -> ResourceResult<[User]> {
        var dictionaries: [[String: Any]]
        if dictionary[MixedUpAPI.usersKey] as? [[String: Any]] != nil {
            dictionaries = (dictionary[MixedUpAPI.usersKey] as? [[String: Any]])!
        } else if dictionary[MixedUpAPI.userKey] as? [[String: Any]] != nil {
            dictionaries = (dictionary[MixedUpAPI.userKey] as? [[String: Any]])!
        } else {
            return .failure(Errors.invalidJSONData)
        }
        var actualUsers: [User] = []
        for dictionary in dictionaries {
            if let user = getUserFromDictionary(dictionary, inContext: context){
                actualUsers.append(user)
            }
        }
        if actualUsers.count == 0 && dictionaries.count > 0 {
            return .failure(Errors.invalidJSONData)
        }
        return .success(actualUsers)
    }
    
    static func getUserFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> User?{
        var dictionary = dictionary
        if dictionary[MixedUpAPI.userKey] != nil {
            dictionary = (dictionary[MixedUpAPI.usersKey] as? [String: Any])!
        }
        
        guard let id = dictionary[MixedUpAPI.idKey] as? String else { return nil}
        if let cdUser: User = MixedUpAPI.getFromCoreData(typeName: MixedUpAPI.userTypeKey, id: id, context: context){
            return cdUser
        }
        
        var user: User!
        context.performAndWait({ () -> Void in
            user = NSEntityDescription.insertNewObject(forEntityName: User.entityName,
                                                       into: context) as! User
            user.email = dictionary[MixedUpAPI.emailKey] as? String ?? nil
            let inventory = dictionary[MixedUpAPI.inventoryKey] as? [[String: Any]]
            var actualIngredients: [Ingredient] = []
            if let ingredients = inventory{
                for theIngredient in ingredients {
                    if let ingredient = getIngredientFromDictionary(theIngredient, inContext: context){
                        actualIngredients.append(ingredient)
                    }
                }
                if actualIngredients.count == ingredients.count {
                    let set: Set<Ingredient> = Set(actualIngredients)
                    user.inventory = set as NSSet?
                } else{
                    user.inventory = []
                }
            } else {
                user.inventory = []
            }
            user.id = id
            let favDrinks = dictionary[MixedUpAPI.favoriteDrinksKey] as? [[String: Any]]
            var actualDrinks: [Drink] = []
            if let drinks = favDrinks{
                for drink in drinks {
                    if let drink = getDrinkFromDictionary(drink, inContext: context){
                        actualDrinks.append(drink)
                    }
                }
                if drinks.count == actualDrinks.count {
                    user.favoriteDrinks = Set(actualDrinks) as NSSet?
                } else{
                    user.favoriteDrinks = []
                }
            }  else {
                user.favoriteDrinks = []
            }
            let theBars = dictionary[MixedUpAPI.barsManagedKey] as? [[String: Any]]
            var actualBars: [Bar] = []
            if let bars = theBars{
                for bar in bars {
                    if let bar = getBarfromDictionary(bar, inContext: context){
                        actualBars.append(bar)
                    }
                }
                if bars.count == actualBars.count {
                    user.barsManaged = Set(actualBars) as NSSet?
                } else{
                    user.barsManaged = []
                }
            }  else {
                user.barsManaged = []
            }
        })
        return user
    }
    
    
    static func getDrinksFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> ResourceResult<[Drink]>{
        let dictionaries: [[String: Any]]
        if dictionary[MixedUpAPI.drinksKey] as? [[String: Any]] != nil {
            dictionaries = (dictionary[MixedUpAPI.drinksKey] as? [[String: Any]])!
        } else if dictionary[MixedUpAPI.favoriteDrinksKey] as? [[String: Any]] != nil {
            dictionaries = (dictionary[MixedUpAPI.favoriteDrinksKey] as? [[String: Any]])!
        } else if dictionary[MixedUpAPI.menuKey] as? [[String: Any]] != nil {
            dictionaries = (dictionary[MixedUpAPI.menuKey] as? [[String: Any]])!
        } else if dictionary[MixedUpAPI.specialtiesKey] as? [[String: Any]] != nil {
            dictionaries = (dictionary[MixedUpAPI.specialtiesKey] as? [[String: Any]])!
        } else {
            return .failure(Errors.invalidJSONData)
        }
        
        var actualDrinks: [Drink] = []
        for dictionary in dictionaries {
            if let drink = getDrinkFromDictionary(dictionary, inContext: context){
                print("loop within \(#function)")
                debugPrintSingleDrink(drink: drink)
                actualDrinks.append(drink)
            }
        }
        
        if actualDrinks.count == 0 && dictionaries.count > 0 {
            return .failure(Errors.invalidJSONData)
        }
        
        // TODO: Delete stuff. TJ Added this
        print(#function)
        debugPrintDrinks(drinks: actualDrinks)
        return .success(actualDrinks)
    }
    
    static func getDrinkFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> Drink? {
        
        guard let display = dictionary[MixedUpAPI.displayNameKey] as? String else { return nil}
        let name = dictionary[MixedUpAPI.nameKey] as? String ?? ""
        let isAlcoholic = dictionary[MixedUpAPI.isAlcoholicKey] as? Bool ?? true
        let isIBA = dictionary[MixedUpAPI.isIBAOficialKey] as? Bool ?? true
        let id = dictionary[MixedUpAPI.idKey] as? String ?? UUID().uuidString
        
        if let cdDrink: Drink = MixedUpAPI.getFromCoreData(typeName: MixedUpAPI.drinkTypeKey, id: id, context: context){
            return cdDrink
        }
        
        var drink: Drink!
        context.performAndWait({ () -> Void in
            drink = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName,
                                                        into: context) as! Drink
            drink.name = name
            drink.stringDescription = dictionary[MixedUpAPI.descriptionKey] as? String ?? ""
            drink.id = id
            drink.displayName = display
            drink.isAlcoholic = isAlcoholic
            drink.isIBAOfficial = isIBA
            
            let ingredients = dictionary[MixedUpAPI.ingredientsKey] as? [[String: Any]]
            var actualIngredients: [Ingredient] = []
            if let ingredients = ingredients{
                for theIngredient in ingredients {
                    if let ingredient = getIngredientFromDictionary(theIngredient, inContext: context){
                        actualIngredients.append(ingredient)
                    }
                }
                if actualIngredients.count == ingredients.count {
                    drink.ingredients  = Set(actualIngredients) as NSSet?
                } else{
                    drink.ingredients = []
                }
            }else {
                drink.ingredients = []
            }
            print(dictionary[MixedUpAPI.ingredientsKey] as! [[String:Any]])
            
            let tools = dictionary[MixedUpAPI.toolsKey] as? [[String: Any]]
            var actualTools: [Tool] = []
            if let tools = tools{
                for theTool in tools {
                    if let tool = getToolFromDictionary(theTool, inContext: context){
                        actualTools.append(tool)
                    }
                }
                if actualTools.count == tools.count {
                    drink.tools = Set(actualTools) as NSSet?
                } else{
                    drink.tools = []
                }
            }  else {
                drink.tools = []
            }
            
            if let color = dictionary[MixedUpAPI.colorKey] as? [String: Any] {
                drink.color = getColorFromDictionary(color, inContext: context)
            }
            if let glass = dictionary[MixedUpAPI.glassKey] as? [String: Any] {
                drink.glass = getGlassFromDictionary(glass, inContext: context)
            }
        })
        
        
        return drink
    }
    static func getIngredientTypesFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> ResourceResult<[IngredientType]>{
        let dictionaries: [[String: Any]]
        if dictionary[MixedUpAPI.ingredientTypesKey] as? [[String: Any]] != nil {
            dictionaries = (dictionary[MixedUpAPI.ingredientTypesKey] as? [[String: Any]])!
        } else {
            return .failure(Errors.invalidJSONData)
        }
        
        var actualTypes: [IngredientType] = []
        for dictionary in dictionaries {
            if let type = getIngredientTypeFromDictionary(dictionary, inContext: context){
                actualTypes.append(type)
            }
        }
        
        if actualTypes.count == 0 && dictionaries.count > 0 {
            return .failure(Errors.invalidJSONData)
        }
        return .success(actualTypes)
    }
    
    static func getIngredientTypeFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> IngredientType? {
        
        guard let display = dictionary[MixedUpAPI.displayNameKey] as? String else { return nil}
        let id = dictionary[MixedUpAPI.idKey] as? String ?? UUID().uuidString
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MixedUpAPI.ingredientTypeKey)
        let predicate = NSPredicate(format: "id == \"\(id)\"")
        fetchRequest.predicate = predicate
        
        if let cdIngredientType: IngredientType = MixedUpAPI.getFromCoreData(typeName: MixedUpAPI.ingredientTypeKey, id: id, context: context){
            return cdIngredientType
        }
        var type: IngredientType!
        context.performAndWait({ () -> Void in
            type = NSEntityDescription.insertNewObject(forEntityName: IngredientType.entityName,
                                                       into: context) as! IngredientType
            type.name = dictionary[MixedUpAPI.nameKey] as? String ?? ""
            type.id = id
            type.displayName = display
        })
        return type
    }
    
    static func getGlassFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> Glass? {
        guard let display = dictionary[MixedUpAPI.displayNameKey] as? String  else { return nil}
            let id = dictionary[MixedUpAPI.idKey] as? String  ?? UUID().uuidString
        if let cdGlass: Glass = MixedUpAPI.getFromCoreData(typeName: MixedUpAPI.glassTypeKey, id: id, context: context){
            return cdGlass
        }
        var glass: Glass!
        context.performAndWait({ () -> Void in
            glass = NSEntityDescription.insertNewObject(forEntityName: Glass.entityName,
                                                        into: context) as! Glass
            glass.name = dictionary[MixedUpAPI.nameKey] as? String
            glass.id = id
            glass.displayName = display
        })
        return glass
    }
    
    static func getToolsFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> ResourceResult<[Tool]> {
        guard let dictionaries = dictionary[MixedUpAPI.toolsKey] as? [[String: Any]] else {
            return .failure(Errors.invalidJSONData)
        }
        var actualTools: [Tool] = []
        for dictionary in dictionaries {
            if let tool = getToolFromDictionary(dictionary, inContext: context){
                actualTools.append(tool)
            }
        }
        
        if actualTools.count != dictionaries.count {
            return .failure(Errors.invalidJSONData)
        }
        return .success(actualTools)
    }
    
    static func getToolFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) ->  Tool? {
        guard let display = dictionary[MixedUpAPI.displayNameKey] as? String else { return nil}
            let id = dictionary[MixedUpAPI.idKey] as? String ?? UUID().uuidString
        
        if let cdTool: Tool = MixedUpAPI.getFromCoreData(typeName: MixedUpAPI.toolTypeKey, id: id, context: context){
            return cdTool
        }
        var tool: Tool!
        context.performAndWait({ () -> Void in
            tool = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                       into: context) as! Tool
            tool.name = dictionary[MixedUpAPI.nameKey] as? String
            tool.id = id
            tool.displayName = display
        })
        return tool
    }
    
    
    static func getColorFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> Color?{
        
        guard let display = dictionary[MixedUpAPI.displayNameKey] as? String,
            let red = dictionary[MixedUpAPI.redKey] as? Int16,
            let green = dictionary[MixedUpAPI.greenKey] as? Int16,
            let blue = dictionary[MixedUpAPI.blueKey] as? Int16,
            let alpha = dictionary[MixedUpAPI.alphaKey] as? Int16 else { return nil}
            let id = dictionary[MixedUpAPI.idKey] as? String ?? UUID().uuidString
        
        if let cdColor: Color = MixedUpAPI.getFromCoreData(typeName: MixedUpAPI.colorTypeKey, id: id, context: context){
            return cdColor
        }
        
        var color: Color!
        context.performAndWait({ () -> Void in
            color = NSEntityDescription.insertNewObject(forEntityName: Color.entityName,
                                                        into: context) as! Color
            color.name = dictionary[MixedUpAPI.nameKey] as? String
            color.id = id
            color.displayName = display
            color.red = red
            color.blue = blue
            color.green = green
            color.alpha = alpha
        })
        return color
    }
    
    static func getIngredientsFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> ResourceResult<[Ingredient]> {
        let dictionaries: [[String: Any]]
        
        if dictionary[MixedUpAPI.ingredientsKey] as? [[String: Any]] != nil {
            dictionaries = (dictionary[MixedUpAPI.ingredientsKey] as? [[String: Any]])!
        } else if dictionary[MixedUpAPI.inventoryKey] as? [[String: Any]] != nil {
            dictionaries = (dictionary[MixedUpAPI.inventoryKey] as? [[String: Any]])!
        } else {
            return .failure(Errors.invalidJSONData)
        }
        var actualIngredients: [Ingredient] = []
        for dictionary in dictionaries {
            if let ingredient = getIngredientFromDictionary(dictionary, inContext: context){
                actualIngredients.append(ingredient)
            }
        }
        if actualIngredients.count != dictionaries.count{
            return .failure(Errors.invalidJSONData)
        }
        return .success(actualIngredients)
    }
    
    
    static func getIngredientFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> Ingredient? {
        guard let display = dictionary[MixedUpAPI.displayNameKey] as? String,
            let isAlcoholic = dictionary[MixedUpAPI.isAlcoholicKey] as? Bool else { return nil}
            let id = dictionary[MixedUpAPI.idKey] as? String ?? UUID().uuidString
        if let cdIngredient: Ingredient = MixedUpAPI.getFromCoreData(typeName: MixedUpAPI.ingredientEntityTypeKey, id: id, context: context){
            return cdIngredient
        }
        
        var ingredient: Ingredient!
        context.performAndWait({ () -> Void in
            ingredient = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName, into: context) as! Ingredient
            ingredient.name = dictionary[MixedUpAPI.nameKey] as? String
            ingredient.id = id
            ingredient.displayName = display
            ingredient.isAlcoholic = isAlcoholic
            
            if let type = dictionary[MixedUpAPI.ingredienttypeKey] as? [String: Any] {
                ingredient.type = getIngredientTypeFromDictionary(type, inContext: context)
            } else if let type = dictionary[MixedUpAPI.typeKey] as? [String: Any] {
                ingredient.type = getIngredientTypeFromDictionary(type, inContext: context)
            }
        })
        return ingredient
    }
    
    
    static func getFromCoreData<A>(typeName: String, id: String, context: NSManagedObjectContext) -> A?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: typeName)
        let predicate = NSPredicate(format: "id == \"\(id)\"")
        fetchRequest.predicate = predicate
        
        let fetchedTypes: [A] = {
            var types: [A]!
            context.performAndWait() {
                types = try! context.fetch(fetchRequest) as! [A]
            }
            return types
        }()
        if let firstType = fetchedTypes.first {
            return firstType
        } else {
            return nil
        }
    }
    
    static func getBarsFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> ResourceResult<[Bar]>{
        return .success([])
    }
    
    static func getBarfromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> Bar? {
        return nil
    }
    
    static func getLocationfromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> Location? {
        return nil
    }
}
