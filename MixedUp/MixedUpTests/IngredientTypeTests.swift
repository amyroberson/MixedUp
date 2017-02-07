//
//  IngredientTypeTests.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/7/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import XCTest
import CoreData
@testable import MixedUp

class IngredientTypeTests: XCTestCase {
    
    let stack = CoreDataStack(modelName: "MixedUpDataModel")
    
    
    func testToDictionary(){

        let type = NSEntityDescription.insertNewObject(forEntityName: IngredientType.entityName,
                                                   into: self.stack.privateQueueContext) as! IngredientType
        type.displayName = "Mixer"
        type.name = "mixer"
        type.id = "twv4"
        let dictionary = type.toDictionary()
        let dName = (dictionary["displayName"]) as? String
        let id = (dictionary["id"]) as? String
        let name = (dictionary["name"]) as? String
        
        XCTAssertEqual("Mixer", dName)
        XCTAssertEqual("twv4", id)
        XCTAssertEqual("mixer", name)
    }
    
    func testToDictionary2(){
        
        let type = NSEntityDescription.insertNewObject(forEntityName: IngredientType.entityName,
                                                       into: self.stack.privateQueueContext) as! IngredientType
        type.displayName = "Mixer"
        type.name = "mixer"
        type.id = nil
        let dictionary = type.toDictionary()
        let dName = (dictionary["displayName"]) as? String
        let id = (dictionary["id"]) as? String
        let name = (dictionary["name"]) as? String
        
        XCTAssertEqual("Mixer", dName)
        XCTAssertEqual(nil, id)
        XCTAssertEqual("mixer", name)
    }
    
    func testFromDictionary(){
        let type = NSEntityDescription.insertNewObject(forEntityName: IngredientType.entityName,
                                                       into: self.stack.privateQueueContext) as! IngredientType
        type.displayName = "Mixer"
        type.name = "mixer"
        type.id = "twv4"
        let dictionary = type.toDictionary()
        let object = MixedUpAPI.getIngredientTypeFromDictionary(dictionary, inContext: self.stack.privateQueueContext)
        if let object = object {
            XCTAssertEqual(object.displayName, "Mixer")
            XCTAssertEqual(object.id, "twv4")
            XCTAssertEqual(object.name, "mixer")
        } else {
            XCTAssert(false)
        }
        
    }
    
    
    
}
