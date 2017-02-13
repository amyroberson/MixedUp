//
//  MixedUpAPI.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

//work on generics

class MixedUpAPI {
    enum Error: Swift.Error {
        case invalidJSONData
    }
    
    internal static let baseURL: URL = URL(string:"www.example.com")!
    
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
        if dictionary["users"] as? [[String: Any]] != nil {
            dictionaries = (dictionary["users"] as? [[String: Any]])!
        } else if dictionary["user"] as? [[String: Any]] != nil {
            dictionaries = (dictionary["user"] as? [[String: Any]])!
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
        if dictionary["user"] != nil {
            dictionary = (dictionary["user"] as? [String: Any])!
        }
        
        guard let id = dictionary["id"] as? String else { return nil}
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let predicate = NSPredicate(format: "id == \"\(id)\"")
        fetchRequest.predicate = predicate
        
        let fetchedUsers: [User] = {
            var users: [User]!
            context.performAndWait() {
                users = try! context.fetch(fetchRequest) as! [User]
            }
            return users
        }()
        if let firstUser = fetchedUsers.first {
            return firstUser
        }
        
        var user: User!
        context.performAndWait({ () -> Void in
            user = NSEntityDescription.insertNewObject(forEntityName: User.entityName,
                                                       into: context) as! User
            user.email = dictionary["email"] as? String ?? nil
            let inventory = dictionary["inventory"] as? [[String: Any]]
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
            let favDrinks = dictionary["favoriteDrinks"] as? [[String: Any]]
            var actualDrinks: [Drink] = []
            if let drinks = favDrinks{
                for drink in drinks {
                    if let drink = getDrinkFromDictionary(drink, inContext: context){
                        actualDrinks.append(drink)
                    }
                }
                if drinks.count == actualDrinks.count {
                    let set: Set<Drink> = Set(actualDrinks)
                    user.favoriteDrinks = set as NSSet?
                } else{
                    user.favoriteDrinks = []
                }
            }  else {
                user.favoriteDrinks = []
            }
            let theBars = dictionary["barsManaged"] as? [[String: Any]]
            var actualBars: [Bar] = []
            if let bars = theBars{
                for bar in bars {
                    if let bar = getBarfromDictionary(bar, inContext: context){
                        actualBars.append(bar)
                    }
                }
                if bars.count == actualBars.count {
                    let set: Set<Bar> = Set(actualBars)
                    user.barsManaged = set as NSSet?
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
        if dictionary["drinks"] as? [[String: Any]] != nil {
            dictionaries = (dictionary["drinks"] as? [[String: Any]])!
        } else if dictionary["favoriteDrinks"] as? [[String: Any]] != nil {
            dictionaries = (dictionary["favoriteDrinks"] as? [[String: Any]])!
        } else if dictionary["menu"] as? [[String: Any]] != nil {
            dictionaries = (dictionary["menu"] as? [[String: Any]])!
        } else if dictionary["specialties"] as? [[String: Any]] != nil {
            dictionaries = (dictionary["specialties"] as? [[String: Any]])!
        } else {
            return .failure(Errors.invalidJSONData)
        }
        
        var actualDrinks: [Drink] = []
        for dictionary in dictionaries {
            if let drink = getDrinkFromDictionary(dictionary, inContext: context){
                actualDrinks.append(drink)
            }
        }
        
        if actualDrinks.count == 0 && dictionaries.count > 0 {
            return .failure(Errors.invalidJSONData)
        }
        return .success(actualDrinks)
    }
    
    static func getDrinkFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> Drink? {
        
        guard let display = dictionary["displayName"] as? String else { return nil}
        let name = dictionary["name"] as? String ?? ""
        let isAlcoholic = dictionary["isAlcoholic"] as? Bool ?? true
        let isIBA = dictionary["isIBAOfficial"] as? Bool ?? true
        let id = dictionary["id"] as? String ?? UUID().uuidString
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Drink")
        let predicate = NSPredicate(format: "id == \"\(id)\"")
        fetchRequest.predicate = predicate
        
        let fetchedDrinks: [Drink] = {
            var drinks: [Drink]!
            context.performAndWait() {
                drinks = try! context.fetch(fetchRequest) as! [Drink]
            }
            return drinks
        }()
        if let firstDrink = fetchedDrinks.first {
            return firstDrink
        }
        
        var drink: Drink!
        context.performAndWait({ () -> Void in
            drink = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName,
                                                        into: context) as! Drink
            drink.name = name
            drink.stringDescription = dictionary["description"] as? String ?? ""
            drink.id = id
            drink.displayName = display
            drink.isAlcoholic = isAlcoholic
            drink.isIBAOfficial = isIBA
            
            let ingredients = dictionary["ingredients"] as? [[String: Any]]
            var actualIngredients: [Ingredient] = []
            if let ingredients = ingredients{
                for theIngredient in ingredients {
                    if let ingredient = getIngredientFromDictionary(theIngredient, inContext: context){
                        actualIngredients.append(ingredient)
                    }
                }
                if actualIngredients.count == ingredients.count {
                    let set: Set<Ingredient> = Set(actualIngredients)
                    drink.ingredients = set as NSSet?
                } else{
                    drink.ingredients = []
                }
            }else {
                drink.ingredients = []
            }
            
            let tools = dictionary["tools"] as? [[String: Any]]
            var actualTools: [Tool] = []
            if let tools = tools{
                for theTool in tools {
                    if let tool = getToolFromDictionary(theTool, inContext: context){
                        actualTools.append(tool)
                    }
                }
                if actualTools.count == tools.count {
                    let set: Set<Tool> = Set(actualTools)
                    drink.tools = set as NSSet?
                } else{
                    drink.tools = []
                }
            }  else {
                drink.tools = []
            }
            
            if let color = dictionary["color"] as? [String: Any] {
                let theColor = getColorFromDictionary(color, inContext: context)
                drink.color = theColor
            }
            if let glass = dictionary["glass"] as? [String: Any] {
                let theGlass = getGlassFromDictionary(glass, inContext: context)
                drink.glass = theGlass
            }
        })
        
        return drink
    }
    static func getIngredientTypesFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> ResourceResult<[IngredientType]>{
        let dictionaries: [[String: Any]]
        if dictionary["ingredienttypes"] as? [[String: Any]] != nil {
            dictionaries = (dictionary["ingredienttypes"] as? [[String: Any]])!
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
        
        guard let display = dictionary["displayName"] as? String else { return nil}
        let id = dictionary["id"] as? String ?? UUID().uuidString
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "IngredientType")
        let predicate = NSPredicate(format: "id == \"\(id)\"")
        fetchRequest.predicate = predicate
        
        let fetchedTypes: [IngredientType] = {
            var types: [IngredientType]!
            context.performAndWait() {
                types = try! context.fetch(fetchRequest) as! [IngredientType]
            }
            return types
        }()
        if let firstType = fetchedTypes.first {
            return firstType
        }
        
        
        var type: IngredientType!
        context.performAndWait({ () -> Void in
            type = NSEntityDescription.insertNewObject(forEntityName: IngredientType.entityName,
                                                       into: context) as! IngredientType
            type.name = dictionary["name"] as? String ?? ""
            type.id = id
            type.displayName = display
            
            
        })
        return type
        
    }
    
    static func getGlassFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> Glass? {
        guard let display = dictionary["displayName"] as? String  else { return nil}
            let id = dictionary["id"] as? String  ?? UUID().uuidString
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Glass")
        let predicate = NSPredicate(format: "id == \"\(id)\"")
        fetchRequest.predicate = predicate
        
        let fetchedGlasses: [Glass] = {
            var glasses: [Glass]!
            context.performAndWait() {
                glasses = try! context.fetch(fetchRequest) as! [Glass]
            }
            return glasses
        }()
        if let firstGlass = fetchedGlasses.first {
            return firstGlass
        }
        
        var glass: Glass!
        context.performAndWait({ () -> Void in
            glass = NSEntityDescription.insertNewObject(forEntityName: Glass.entityName,
                                                        into: context) as! Glass
            glass.name = dictionary["name"] as? String
            glass.id = id
            glass.displayName = display
            
            //need to set relationship to drink
            
        })
        return glass
    }
    
    static func getToolsFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> ResourceResult<[Tool]> {
        guard let dictionaries = dictionary["tools"] as? [[String: Any]] else {
            // The JSON structure doesn't match our expectations
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
        guard let display = dictionary["displayName"] as? String else { return nil}
            let id = dictionary["id"] as? String ?? UUID().uuidString
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tool")
        let predicate = NSPredicate(format: "id == \"\(id)\"")
        fetchRequest.predicate = predicate
        
        let fetchedTools: [Tool] = {
            var tools: [Tool]!
            context.performAndWait() {
                tools = try! context.fetch(fetchRequest) as! [Tool]
            }
            return tools
        }()
        if let firstTool = fetchedTools.first {
            return firstTool
        }
        
        var tool: Tool!
        context.performAndWait({ () -> Void in
            tool = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                       into: context) as! Tool
            tool.name = dictionary["name"] as? String
            tool.id = id
            tool.displayName = display
            
            
            //need to set relationship to drink
            
        })
        return tool
    }
    
    
    static func getColorFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> Color?{
        
        guard let display = dictionary["displayName"] as? String,
            let red = dictionary["red"] as? Int16,
            let green = dictionary["green"] as? Int16,
            let blue = dictionary["blue"] as? Int16,
            let alpha = dictionary["alpha"] as? Int16 else { return nil}
            let id = dictionary["id"] as? String ?? UUID().uuidString
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Color")
        let predicate = NSPredicate(format: "id == \"\(id)\"")
        fetchRequest.predicate = predicate
        
        let fetchedColors: [Color] = {
            var colors: [Color]!
            context.performAndWait() {
                colors = try! context.fetch(fetchRequest) as! [Color]
            }
            return colors
        }()
        if let firstColor = fetchedColors.first {
            return firstColor
        }
        
        var color: Color!
        context.performAndWait({ () -> Void in
            color = NSEntityDescription.insertNewObject(forEntityName: Color.entityName,
                                                        into: context) as! Color
            color.name = dictionary["name"] as? String
            color.id = id
            color.displayName = display
            color.red = red
            color.blue = blue
            color.green = green
            color.alpha = alpha
            
            //need to set relationship to drink
            
        })
        return color
    }
    
    static func getIngredientsFromDictionary(_ dictionary:[String: Any], inContext context: NSManagedObjectContext) -> ResourceResult<[Ingredient]> {
        let dictionaries: [[String: Any]]
        
        if dictionary["ingredients"] as? [[String: Any]] != nil {
            dictionaries = (dictionary["ingredients"] as? [[String: Any]])!
        } else if dictionary["inventory"] as? [[String: Any]] != nil {
            dictionaries = (dictionary["inventory"] as? [[String: Any]])!
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
        
        guard let display = dictionary["displayName"] as? String,
            let isAlcoholic = dictionary["isAlcoholic"] as? Bool else { return nil}
            let id = dictionary["id"] as? String ?? UUID().uuidString
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ingredient")
        let predicate = NSPredicate(format: "id == \"\(id)\"")
        fetchRequest.predicate = predicate
        
        let fetchedIngredients: [Ingredient] = {
            var ingredients: [Ingredient]!
            context.performAndWait() {
                ingredients = try! context.fetch(fetchRequest) as! [Ingredient]
            }
            return ingredients
        }()
        if let firstIngredient = fetchedIngredients.first {
            return firstIngredient
        }
        
        var ingredient: Ingredient!
        context.performAndWait({ () -> Void in
            ingredient = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName, into: context) as! Ingredient
            ingredient.name = dictionary["name"] as? String
            ingredient.id = id
            ingredient.displayName = display
            ingredient.isAlcoholic = isAlcoholic
            
            if let type = dictionary["ingredientType"] as? [String: Any] {
                let theType = getIngredientTypeFromDictionary(type, inContext: context)
                ingredient.type = theType
            } else if let type = dictionary["type"] as? [String: Any] {
                let theType = getIngredientTypeFromDictionary(type, inContext: context)
                ingredient.type = theType
            }
        })
        return ingredient
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
