//
//  UtilTests.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/20/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import XCTest
import CoreData
@testable import MixedUp

class UtilTests: XCTestCase {
    
    func testSearch() {
        let managedObjectContext = setUpInMemoryManagedObjectContext()
        let drink1 = NSEntityDescription.insertNewObject(forEntityName: "Drink", into: managedObjectContext) as! Drink
        let ingredient1 = NSEntityDescription.insertNewObject(forEntityName: "Ingredient", into: managedObjectContext) as! Ingredient
        let type = NSEntityDescription.insertNewObject(forEntityName: "IngredientType", into: managedObjectContext) as! IngredientType
        let tool = NSEntityDescription.insertNewObject(forEntityName: "Tool", into: managedObjectContext) as! Tool
        tool.displayName = "Muddler"
        drink1.tools = drink1.tools?.adding(tool) as NSSet?
        type.displayName = "Mixer"
        type.name = "mixer"
        ingredient1.type = type
        ingredient1.displayName = "Cola"
        ingredient1.isAlcoholic = false
        drink1.ingredients = drink1.ingredients?.adding(ingredient1) as NSSet?
        drink1.displayName = "Soda"
        
        let x = Util.searchDrinks(allDrinks: [drink1], searchText: "Cola")
        XCTAssertEqual(x, [drink1])
        let y = Util.searchDrinks(allDrinks: [drink1], searchText: "soda")
        XCTAssertEqual(y, [drink1])
    }
    
    func testAlcoholic(){
        let managedObjectContext = setUpInMemoryManagedObjectContext()
        let drink1 = NSEntityDescription.insertNewObject(forEntityName: "Drink", into: managedObjectContext) as! Drink
        let ingredient1 = NSEntityDescription.insertNewObject(forEntityName: "Ingredient", into: managedObjectContext) as! Ingredient
        let type = NSEntityDescription.insertNewObject(forEntityName: "IngredientType", into: managedObjectContext) as! IngredientType
        let ingredient2 = NSEntityDescription.insertNewObject(forEntityName: "Ingredient", into: managedObjectContext) as! Ingredient
        let tool = NSEntityDescription.insertNewObject(forEntityName: "Tool", into: managedObjectContext) as! Tool
        tool.displayName = "Muddler"
        drink1.tools = drink1.tools?.adding(tool) as NSSet?
        type.displayName = "Mixer"
        type.name = "mixer"
        ingredient1.type = type
        ingredient1.displayName = "Cola"
        ingredient1.isAlcoholic = false
        ingredient2.isAlcoholic = true
        drink1.ingredients = drink1.ingredients?.adding(ingredient1) as NSSet?
        drink1.displayName = "Soda"
        let x = Util.getIsAlcoholic(ingredients:[ingredient1])
        XCTAssertFalse(x)
        let y = Util.getIsAlcoholic(ingredients: [ingredient1, ingredient2])
        XCTAssert(y)
    }
    
    
    func testMissingIgredients(){
        let managedObjectContext = setUpInMemoryManagedObjectContext()
        let drink1 = NSEntityDescription.insertNewObject(forEntityName: "Drink", into: managedObjectContext) as! Drink
        let ingredient1 = NSEntityDescription.insertNewObject(forEntityName: "Ingredient", into: managedObjectContext) as! Ingredient
        let type = NSEntityDescription.insertNewObject(forEntityName: "IngredientType", into: managedObjectContext) as! IngredientType
        let ingredient2 = NSEntityDescription.insertNewObject(forEntityName: "Ingredient", into: managedObjectContext) as! Ingredient
        let tool = NSEntityDescription.insertNewObject(forEntityName: "Tool", into: managedObjectContext) as! Tool
        tool.displayName = "Muddler"
        drink1.tools = drink1.tools?.adding(tool) as NSSet?
        type.displayName = "Mixer"
        type.name = "mixer"
        ingredient1.type = type
        ingredient1.displayName = "Cola"
        ingredient1.isAlcoholic = false
        ingredient2.isAlcoholic = true
        drink1.ingredients = drink1.ingredients?.adding(ingredient1) as NSSet?
        drink1.displayName = "Soda"
        let missing = Util.getMissingIngredients([ingredient2], [ingredient1])
        XCTAssertEqual(missing, [ingredient1])
        
    }

    
}
