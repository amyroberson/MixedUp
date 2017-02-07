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
        let ingredients = dictionary["ingredients"] as? [[String: Any?]]
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
        let theIngredients = ingredients!! as? [String: Any]
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
    
}
