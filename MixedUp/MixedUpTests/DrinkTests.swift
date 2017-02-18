//
//  DrinkTests.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/7/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import XCTest
import CoreData
@testable import MixedUp

class DrinkTests: XCTestCase {
    
    let stack = CoreDataStack(modelName: "MixedUpDataModel")
    
    
    func testToDictionary(){
        
        let drink = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName,
                                                       into: self.stack.privateQueueContext) as! Drink
        drink.displayName = "Mixer"
        drink.name = "mixer"
        drink.id = "twv4"
        let rum = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                      into: self.stack.privateQueueContext) as! Ingredient
        rum.name = "rum"
        drink.ingredients = [rum]
        let shaker = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                         into: self.stack.privateQueueContext) as! Tool
        shaker.name = "shaker"
        drink.tools = [shaker]
        
        let dictionary = drink.toDictionary()
        let dName = (dictionary["displayName"]) as? String
        let id = (dictionary["id"]) as? String
        let name = (dictionary["name"]) as? String
        let ingredients = dictionary["ingredients"] as? [[String: Any]]
        let tools = dictionary["tools"] as? [[String: Any]]
        let tool = tools?[0]
        let tName = tool?["name"] as? String
        let firstIngredient = ingredients?[0]
        let ingredient = firstIngredient?["name"] as? String
        
        XCTAssertEqual("Mixer", dName)
        XCTAssertEqual("twv4", id)
        XCTAssertEqual("mixer", name)
        XCTAssertEqual(ingredient, "rum")
        XCTAssertEqual(tName!, "shaker")
        
    }
    
    func testToDictionary2(){
        
        let drink = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName,
                                                        into: self.stack.privateQueueContext) as! Drink
        drink.displayName = "Mixer"
        drink.name = "mixer"
        drink.id = "twv4"
        let shaker = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                         into: self.stack.privateQueueContext) as! Tool
        shaker.name = "shaker"
        drink.tools = [shaker]
        
        let dictionary = drink.toDictionary()
        let dName = (dictionary["displayName"]) as? String
        let id = (dictionary["id"]) as? String
        let name = (dictionary["name"]) as? String
        let ingredients = dictionary["ingredients"]
        let theIngredients = ingredients! as? [String: Any]
        let tools = dictionary["tools"] as? [[String: Any]]
        let tool = tools?[0]
        let tName = tool?["name"] as? String
        
        if let dict: Dictionary = theIngredients{
            XCTAssertEqual(dict.count, 0)
            
        }
        
        XCTAssertEqual("Mixer", dName)
        XCTAssertEqual("twv4", id)
        XCTAssertEqual("mixer", name)
        XCTAssertEqual(tName!, "shaker")
        
    }
    
    func testFromDictionary(){
        let drink = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName,
                                                             into: self.stack.privateQueueContext) as! Drink
        drink.displayName = "Mixer"
        drink.name = "mixer"
        drink.id = "twv4"
        let rum = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                      into: self.stack.privateQueueContext) as! Ingredient
        rum.name = "rum"
        let shaker = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                         into: self.stack.privateQueueContext) as! Tool
        shaker.name = "shaker"
        drink.tools = [shaker]
        
        let dictionary = drink.toDictionary()
        let object = MixedUpAPI.getDrinkFromDictionary(dictionary, inContext: self.stack.privateQueueContext)
        if let object = object {
            XCTAssertEqual(object.id, "twv4")
            XCTAssertEqual(object.tools?.count, 1)
        } else {
            XCTAssert(false)
        }
    }
    
    func testDrinksFromDictionary(){
        let drink = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName,
                                                        into: self.stack.privateQueueContext) as! Drink
        drink.displayName = "Mixer"
        drink.name = "mixer"
        drink.id = "twv4"
        let rum = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                      into: self.stack.privateQueueContext) as! Ingredient
        rum.name = "rum"
        let shaker = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                         into: self.stack.privateQueueContext) as! Tool
        shaker.name = "shaker"
        drink.tools = [shaker]
        
        let dictionary = drink.toDictionary()
        
        let drink2 = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName,
                                                        into: self.stack.privateQueueContext) as! Drink
        drink2.displayName = "Mixer"
        drink2.name = "mixer"
        drink2.id = "twv4"
        let rum2 = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                      into: self.stack.privateQueueContext) as! Ingredient
        rum2.name = "rum"
        let shaker2 = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                         into: self.stack.privateQueueContext) as! Tool
        shaker2.name = "shaker"
        drink2.tools = [shaker]
        
        let dictionary2 = drink.toDictionary()
        let these: [[String:Any]] =  [dictionary, dictionary2]
        let dicts: [String:Any] = ["favoriteDrinks": these]
        
        let drinks = MixedUpAPI.getDrinksFromDictionary(dicts, inContext: self.stack.privateQueueContext)
        switch drinks{
        case .success(let mixers):
            XCTAssertEqual(mixers.count, 2)
        default:
            XCTAssert(false)
        }
        
        let dicts2: [String:Any] = ["drinks": these]
        let drinks2 = MixedUpAPI.getDrinksFromDictionary(dicts2, inContext: self.stack.privateQueueContext)
        switch drinks2{
        case .success(let mixers):
            XCTAssertEqual(mixers.count, 2)
        default:
            XCTAssert(false)
        }

        let dicts3: [String:Any] = ["menu": these]
        let drinks3 = MixedUpAPI.getDrinksFromDictionary(dicts3, inContext: self.stack.privateQueueContext)
        switch drinks3{
        case .success(let mixers):
            XCTAssertEqual(mixers.count, 2)
        default:
            XCTAssert(false)
        }
        
        let dicts4: [String:Any] = ["specialties": these]
        let drinks4 = MixedUpAPI.getDrinksFromDictionary(dicts4, inContext: self.stack.privateQueueContext)
        switch drinks4{
        case .success(let mixers):
            XCTAssertEqual(mixers.count, 2)
        default:
            XCTAssert(false)
        }
    }
}
