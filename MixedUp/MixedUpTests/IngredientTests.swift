//
//  IngredientTests.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/7/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import XCTest
import CoreData
@testable import MixedUp

class IngredientTests: XCTestCase {
    
    let stack = CoreDataStack(modelName: "MixedUpDataModel")
    
    
    func testToDictionary(){
        
        let ingredient = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                       into: self.stack.privateQueueContext) as! Ingredient
        ingredient.displayName = "Sprite"
        ingredient.name = "sprite"
        ingredient.id = "twv4"
        ingredient.isAlcoholic = false
        ingredient.type = NSEntityDescription.insertNewObject(forEntityName: IngredientType.entityName,
                                                              into: self.stack.privateQueueContext) as? IngredientType
        ingredient.type?.displayName = "Mixer"
        ingredient.type?.name = "mixer"
        
        let dictionary = ingredient.toDictionary()
        let dName = (dictionary["displayName"]) as? String
        let id = (dictionary["id"]) as? String
        let name = (dictionary["name"]) as? String
        let isAlc = (dictionary["isAlcoholic"]) as? Bool
        let type = dictionary["type"] as? [String: Any]
        let tName = type?["name"] as? String
        
        XCTAssertEqual("Sprite", dName)
        XCTAssertEqual("twv4", id)
        XCTAssertEqual("sprite", name)
        XCTAssertEqual(isAlc, false)
        XCTAssertEqual(tName, "mixer")
    }
    
    func testToDictionary2(){
        
        let ingredient = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                             into: self.stack.privateQueueContext) as! Ingredient
        ingredient.displayName = "Sprite"
        ingredient.name = nil
        ingredient.id = nil
        ingredient.isAlcoholic = false
        ingredient.type = NSEntityDescription.insertNewObject(forEntityName: IngredientType.entityName,
                                                              into: self.stack.privateQueueContext) as? IngredientType
        ingredient.type?.displayName = "Mixer"
        ingredient.type?.name = "mixer"
        
        let dictionary = ingredient.toDictionary()
        let dName = (dictionary["displayName"]) as? String
        let id = (dictionary["id"]) as? String
        let name = (dictionary["name"]) as? String
        let isAlc = (dictionary["isAlcoholic"]) as? Bool
        let type = dictionary["type"] as? [String: Any]
        let tName = type?["name"] as? String
        
        XCTAssertEqual("Sprite", dName)
        XCTAssertEqual(nil, id)
        XCTAssertEqual(nil, name)
        XCTAssertEqual(isAlc, false)
        XCTAssertEqual(tName, "mixer")
    }
    
    func testFromDictionary(){
        let ingredient = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                             into: self.stack.privateQueueContext) as! Ingredient
        ingredient.displayName = "Sprite"
        ingredient.name = "sprite"
        ingredient.id = "dgeag"
        ingredient.isAlcoholic = false
        ingredient.type = NSEntityDescription.insertNewObject(forEntityName: IngredientType.entityName,
                                                              into: self.stack.privateQueueContext) as? IngredientType
        ingredient.type?.displayName = "Mixer"
        ingredient.type?.name = "mixer"
        
        let dictionary = ingredient.toDictionary()
        
        let object = MixedUpAPI.getIngredientFromDictionary(dictionary, inContext: self.stack.privateQueueContext)
        if let object = object {
            XCTAssertEqual(object.displayName, "Sprite")
            XCTAssertEqual(object.id, "dgeag")
            XCTAssertEqual(object.name, "sprite")
            XCTAssertEqual(object.type?.name!, "mixer")
        } else {
            XCTAssert(false)
        }
    
    }
    
    func testIngredientsFromDictionay(){
        let ingredient = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                             into: self.stack.privateQueueContext) as! Ingredient
        ingredient.displayName = "Sprite"
        ingredient.name = "sprite"
        ingredient.id = "dgeag"
        ingredient.isAlcoholic = false
        ingredient.type = NSEntityDescription.insertNewObject(forEntityName: IngredientType.entityName,
                                                              into: self.stack.privateQueueContext) as? IngredientType
        ingredient.type?.displayName = "Mixer"
        ingredient.type?.name = "mixer"
        
        let dictionary = ingredient.toDictionary()

        let ingredient2 = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                             into: self.stack.privateQueueContext) as! Ingredient
        ingredient2.displayName = "Coke"
        ingredient2.name = "coke"
        ingredient2.id = "dg543"
        ingredient2.isAlcoholic = false
        ingredient2.type = NSEntityDescription.insertNewObject(forEntityName: IngredientType.entityName,
                                                              into: self.stack.privateQueueContext) as? IngredientType
        ingredient2.type?.displayName = "Mixer"
        ingredient2.type?.name = "mixer"
        
        let dictionary2 = ingredient.toDictionary()
        let ingredients: [[String: Any]] = [dictionary, dictionary2]

        let dict: [String: Any] = ["ingredients": ingredients]
        let sodas = MixedUpAPI.getIngredientsFromDictionary(dict, inContext: self.stack.privateQueueContext)
        switch sodas{
        case .success(let mixers):
            XCTAssertEqual(mixers.count, 2)
        default:
            print(sodas)
            XCTAssert(false)
        }
        
        
        let dict2: [String: Any] = ["inventory": ingredients]
        let sodas2 = MixedUpAPI.getIngredientsFromDictionary(dict2, inContext: self.stack.privateQueueContext)
        switch sodas2{
        case .success(let mixers):
            XCTAssertEqual(mixers.count, 2)
        default:
            print(sodas2)
            XCTAssert(false)
        }
        
        
    }
}
