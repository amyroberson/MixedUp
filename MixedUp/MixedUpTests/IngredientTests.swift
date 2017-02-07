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
}
