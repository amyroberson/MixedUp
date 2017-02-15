//
//  Drink+CoreDataProperties.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData


extension Drink {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Drink> {
        return NSFetchRequest<Drink>(entityName: "Drink");
    }

    @NSManaged public var name: String?
    @NSManaged public var displayName: String?
    @NSManaged public var isAlcoholic: Bool
    @NSManaged public var isIBAOfficial: Bool
    @NSManaged public var stringDescription: String?
    @NSManaged public var id: String?
    @NSManaged public var ingredients: NSSet?
    @NSManaged public var tools: NSSet?
    @NSManaged public var color: Color?
    @NSManaged public var glass: Glass?
    @NSManaged public var user: User?
    @NSManaged public var barmenu: Bar?
    @NSManaged public var barspecialties: Bar?
    @NSManaged public var bardrinks: Bar?

}

// MARK: Generated accessors for ingredients
extension Drink {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredient)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredient)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}

// MARK: Generated accessors for tools
extension Drink {

    @objc(addToolsObject:)
    @NSManaged public func addToTools(_ value: Tool)

    @objc(removeToolsObject:)
    @NSManaged public func removeFromTools(_ value: Tool)

    @objc(addTools:)
    @NSManaged public func addToTools(_ values: NSSet)

    @objc(removeTools:)
    @NSManaged public func removeFromTools(_ values: NSSet)

}
