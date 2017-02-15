//
//  UserTests.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/7/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import XCTest
import CoreData
@testable import MixedUp

class UserTests: XCTestCase {
    
    let stack = CoreDataStack(modelName: "MixedUpDataModel")
    

    func testToDictionary() {
        let user = NSEntityDescription.insertNewObject(forEntityName: User.entityName,
                                                       into: self.stack.privateQueueContext) as! User
        user.email = "bob@example.com"
        user.id = "bob234"
        let rum = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                      into: self.stack.privateQueueContext) as! Ingredient
        rum.name = "rum"
        user.inventory = [rum]
        
        let drink = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName,
                                                        into: self.stack.privateQueueContext) as! Drink
        drink.displayName = "Mixer"
        drink.name = "mixer"
        drink.id = "twv4"
        let vodka = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                      into: self.stack.privateQueueContext) as! Ingredient
        vodka.name = "vodka"
        drink.ingredients = [vodka]
        let shaker = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                         into: self.stack.privateQueueContext) as! Tool
        shaker.name = "shaker"
        drink.tools = [shaker]
        user.favoriteDrinks = [drink]
        let dict = user.toDictionary()
        let id = dict["id"] as? String
        let email = dict["email"] as? String
        let inventory = dict["inventory"] as? [[String: Any]]
        let one = (inventory?[0]["name"]) as! String
        let drinks = dict["favoriteDrinks"] as? [[String: Any]]
        let two = (drinks?[0]["name"]) as! String
        
        XCTAssertEqual(id, "bob234")
        XCTAssertEqual(email, "bob@example.com")
        XCTAssertEqual(one, "rum")
        XCTAssertEqual(two, "mixer")
        
    }
    
    func testFromDictionary(){
        let user = NSEntityDescription.insertNewObject(forEntityName: User.entityName,
                                                       into: self.stack.privateQueueContext) as! User
        user.email = "bob@example.com"
        user.id = "bob234"
        let rum = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                      into: self.stack.privateQueueContext) as! Ingredient
        rum.name = "rum"
        user.inventory = [rum]
        
        let drink = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName,
                                                        into: self.stack.privateQueueContext) as! Drink
        drink.displayName = "Mixer"
        drink.name = "mixer"
        drink.id = "twv4"
        let vodka = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                        into: self.stack.privateQueueContext) as! Ingredient
        vodka.name = "vodka"
        drink.ingredients = [vodka]
        let shaker = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                         into: self.stack.privateQueueContext) as! Tool
        shaker.name = "shaker"
        drink.tools = [shaker]
        user.favoriteDrinks = [drink]
        let dict = user.toDictionary()
        let object = MixedUpAPI.getUserFromDictionary(dict, inContext: self.stack.privateQueueContext)
        if let object = object{
            XCTAssertEqual(object.email, "bob@example.com")
            XCTAssertEqual((object.favoriteDrinks?.count)!, 1)
        } else {
            XCTAssert(false)
        }
    }
    
    func testGetUsers(){
        let user = NSEntityDescription.insertNewObject(forEntityName: User.entityName,
                                                       into: self.stack.privateQueueContext) as! User
        user.email = "bob@example.com"
        user.id = "bob234"
        let rum = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                      into: self.stack.privateQueueContext) as! Ingredient
        rum.name = "rum"
        user.inventory = [rum]
        
        let drink = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName,
                                                        into: self.stack.privateQueueContext) as! Drink
        drink.displayName = "Mixer"
        drink.name = "mixer"
        drink.id = "twv4"
        let vodka = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                        into: self.stack.privateQueueContext) as! Ingredient
        vodka.name = "vodka"
        drink.ingredients = [vodka]
        let shaker = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                         into: self.stack.privateQueueContext) as! Tool
        shaker.name = "shaker"
        drink.tools = [shaker]

        let user2 = NSEntityDescription.insertNewObject(forEntityName: User.entityName,
                                                       into: self.stack.privateQueueContext) as! User
        user2.email = "Jane@example.com"
        user2.id = "Jane234"
        let rum2 = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                      into: self.stack.privateQueueContext) as! Ingredient
        rum2.name = "rum"
        user.inventory = [rum]
        
        let drink2 = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName,
                                                        into: self.stack.privateQueueContext) as! Drink
        drink2.displayName = "Mixer"
        drink2.name = "mixer"
        drink2.id = "twv45"
        let vodka2 = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                        into: self.stack.privateQueueContext) as! Ingredient
        vodka2.name = "vodka"
        drink2.ingredients = [vodka]
        let shaker2 = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                         into: self.stack.privateQueueContext) as! Tool
        shaker2.name = "shaker"
        drink2.tools = [shaker]
        
        let dictionary1 = user.toDictionary()
        let dictionary2 = user2.toDictionary()
        let theDictionary: [String: Any] = ["users" : [dictionary1, dictionary2]]
        
        let users = MixedUpAPI.getUsersFromDictionary(theDictionary, inContext: self.stack.privateQueueContext)
        switch users{
        case .success(let users):
            XCTAssertEqual(users.count, 2)
        default:
            XCTAssert(false)
        }
        
    

    }
    
    
}
