//
//  CoreDataTests.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/15/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import XCTest

import CoreData

class TestsUsingModelFromCoreData: XCTestCase {
    func testSomethingUsingCoreData() {
        let managedObjectContext = setUpInMemoryManagedObjectContext()
        let _ = NSEntityDescription.insertNewObject(forEntityName: "IngredientType", into: managedObjectContext)
        
        }
}
