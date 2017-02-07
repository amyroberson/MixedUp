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

    func testFromDictionary(){
        
        let tool = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                       into: self.stack.privateQueueContext) as! Tool
        tool.displayName = "Spoon"
        tool.name = "spoon"
        tool.id = "dgeag"
        let dictionary = tool.toDictionary()
        let object = MixedUpAPI.getToolFromDictionary(dictionary, inContext: self.stack.privateQueueContext)
        if let object = object {
            XCTAssertEqual(object.displayName, "Spoon")
            XCTAssertEqual(object.id, "dgeag")
            XCTAssertEqual(object.name, "spoon")
        } else {
            XCTAssert(false)
        }
        
    }
    
    func testToolsFromDictionary(){
        let tool = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                       into: self.stack.privateQueueContext) as! Tool
        tool.displayName = "Spoon"
        tool.name = "spoon"
        tool.id = "bar234"
        let dictionary = tool.toDictionary()
        
        let tool2 = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                       into: self.stack.privateQueueContext) as! Tool
        tool2.displayName = "Shaker"
        tool2.name = "shaker"
        tool2.id = "foo134"
        let dictionary2 = tool2.toDictionary()
        
        let tools = [dictionary, dictionary2]
        let theDict: [String: Any] = ["tools" : tools]
        let result = MixedUpAPI.getToolsFromDictionary(theDict, inContext: self.stack.privateQueueContext)
        switch result {
        case .success(let tools):
            XCTAssertEqual(tools.count, 2)
        default:
            print(result)
            XCTAssert(false)
        }
    }
}
