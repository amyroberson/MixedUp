//
//  GlassTests.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import XCTest
import CoreData
@testable import MixedUp

class GlassTests: XCTestCase {
    
    let stack = CoreDataStack(modelName: "MixedUpDataModel")
    
    
    func testToDictionary(){
        
        let glass = NSEntityDescription.insertNewObject(forEntityName: Glass.entityName,
                                                       into: self.stack.privateQueueContext) as! Glass
        glass.displayName = "Martini"
        glass.name = "martini-glass"
        glass.id = "twv4"
        let dictionary = glass.toDictionary()
        let dName = (dictionary["displayName"]) as? String
        let id = (dictionary["id"]) as? String
        let name = (dictionary["name"]) as? String
        
        XCTAssertEqual("Martini", dName)
        XCTAssertEqual("twv4", id)
        XCTAssertEqual("martini-glass", name)
    }
    
    func testToDictionary2(){
        
        let glass = NSEntityDescription.insertNewObject(forEntityName: Glass.entityName,
                                                        into: self.stack.privateQueueContext) as! Glass
        glass.displayName = "Martini"
        glass.name = "martini-glass"
        glass.id = nil
        let dictionary = glass.toDictionary()
        let dName = (dictionary["displayName"]) as? String
        let id = (dictionary["id"]) as? String
        let name = (dictionary["name"]) as? String
        
        XCTAssertEqual("Martini", dName)
        XCTAssertEqual(nil, id)
        XCTAssertEqual("martini-glass", name)
    }
    
}
