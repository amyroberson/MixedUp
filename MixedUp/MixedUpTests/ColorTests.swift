//
//  ColorTests.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/7/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import XCTest
import CoreData
@testable import MixedUp

class ColorTests: XCTestCase {
    

    let stack = CoreDataStack(modelName: "MixedUpDataModel")
    
    
    func testToDictionary(){
        
        let color = NSEntityDescription.insertNewObject(forEntityName: Color.entityName,
                                                        into: self.stack.privateQueueContext) as! Color
        color.displayName = "Blue"
        color.name = "blue"
        color.id = "twv4"
        color.red = 231
        color.alpha = 1
        color.green = 232
        color.blue = 231
        let dictionary = color.toDictionary()
        let dName = (dictionary["displayName"]) as? String
        let id = (dictionary["id"]) as? String
        let name = (dictionary["name"]) as? String
        let blue = (dictionary["blue"]) as? Int16
        let red = (dictionary["red"]) as? Int16
        let green = (dictionary["green"]) as? Int16
        let alpha = (dictionary["alpha"]) as? Int16
        
        XCTAssertEqual("Blue", dName)
        XCTAssertEqual("twv4", id)
        XCTAssertEqual("blue", name)
        XCTAssertEqual(231, blue)
        XCTAssertEqual(1, alpha)
        XCTAssertEqual(red, 231)
        XCTAssertEqual(green, 232)
    }
    
    func testToDictionary2(){
        
        let color = NSEntityDescription.insertNewObject(forEntityName: Color.entityName,
                                                        into: self.stack.privateQueueContext) as! Color
        color.displayName = "Blue"
        color.name = nil
        color.id = nil
        color.red = 231
        color.alpha = 1
        color.green = 232
        color.blue = 231
        let dictionary = color.toDictionary()
        let dName = (dictionary["displayName"]) as? String
        let id = (dictionary["id"]) as? String
        let name = (dictionary["name"]) as? String
        let blue = (dictionary["blue"]) as? Int16
        let red = (dictionary["red"]) as? Int16
        let green = (dictionary["green"]) as? Int16
        let alpha = (dictionary["alpha"]) as? Int16
        
        XCTAssertEqual("Blue", dName)
        XCTAssertEqual(nil, id)
        XCTAssertEqual(nil, name)
        XCTAssertEqual(231, blue)
        XCTAssertEqual(1, alpha)
        XCTAssertEqual(red, 231)
        XCTAssertEqual(green, 232)
    }
    
}
