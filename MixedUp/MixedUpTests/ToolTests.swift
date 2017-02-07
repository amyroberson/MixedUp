//
//  ToolTests.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import XCTest
import CoreData
@testable import MixedUp

class ToolTests: XCTestCase {
    
    let stack = CoreDataStack(modelName: "MixedUpDataModel")
    
    
    func testToDictionary(){
        
        let tool = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                        into: self.stack.privateQueueContext) as! Tool
        tool.displayName = "Spoon"
        tool.name = "spoon"
        tool.id = "twv4"
        let dictionary = tool.toDictionary()
        let dName = (dictionary["displayName"]) as? String
        let id = (dictionary["id"]) as? String
        let name = (dictionary["name"]) as? String
        
        XCTAssertEqual("Spoon", dName)
        XCTAssertEqual("twv4", id)
        XCTAssertEqual("spoon", name)
    }
    
    func testToDictionary2(){
        
        let tool = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                       into: self.stack.privateQueueContext) as! Tool
        tool.displayName = "Spoon"
        tool.name = "spoon"
        tool.id = nil
        let dictionary = tool.toDictionary()
        let dName = (dictionary["displayName"]) as? String
        let id = (dictionary["id"]) as? String
        let name = (dictionary["name"]) as? String
        
        XCTAssertEqual("Spoon", dName)
        XCTAssertEqual(nil, id)
        XCTAssertEqual("spoon", name)
    }

}
