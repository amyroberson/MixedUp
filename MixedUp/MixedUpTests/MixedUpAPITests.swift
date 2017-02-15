//
//  MixedUpAPITests.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/7/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import XCTest
import CoreData
@testable import MixedUp

class MixedUpAPITests: XCTestCase {
    
    let stack = CoreDataStack(modelName: "MixedUpDataModel")

    func testJSON(){
        let dict: [String: Any] = [
            "name": "Bob",
            "drinks": 5,
            "isFun": false]
        do{
            let data = try MixedUpAPI.dictionaryToJson(dict)
            let dictionary = try MixedUpAPI.jsonToDictionary(data)
            XCTAssertEqual(dictionary["name"] as! String, dict["name"] as! String)
            XCTAssertEqual(dictionary["drinks"] as! Int, dict["drinks"] as! Int)
            XCTAssertEqual(dictionary["isFun"] as! Bool, dict["isFun"] as! Bool)
        }catch{
            XCTAssert(false)
        }
    }
   
    
}
