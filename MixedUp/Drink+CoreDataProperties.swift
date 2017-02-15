//
//  Drink+CoreDataProperties.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/15/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData


extension Drink {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Drink> {
        return NSFetchRequest<Drink>(entityName: "Drink");
    }

    @NSManaged public var displayName: String?
    @NSManaged public var id: String?
    @NSManaged public var isAlcoholic: Bool
    @NSManaged public var isIBAOfficial: Bool
    @NSManaged public var name: String?
    @NSManaged public var stringDescription: String?
    @NSManaged public var bardrinks: NSSet?
    @NSManaged public var barmenu: NSSet?
    @NSManaged public var barspecialties: NSSet?
    @NSManaged public var color: Color?
    @NSManaged public var glass: Glass?
    @NSManaged public var ingredients: NSSet?
    @NSManaged public var tools: NSSet?
    @NSManaged public var user: User?

}

// MARK: Generated accessors for bardrinks
extension Drink {

    @objc(addBardrinksObject:)
    @NSManaged public func addToBardrinks(_ value: Bar)

    @objc(removeBardrinksObject:)
    @NSManaged public func removeFromBardrinks(_ value: Bar)

    @objc(addBardrinks:)
    @NSManaged public func addToBardrinks(_ values: NSSet)

    @objc(removeBardrinks:)
    @NSManaged public func removeFromBardrinks(_ values: NSSet)

}

// MARK: Generated accessors for barmenu
extension Drink {

    @objc(addBarmenuObject:)
    @NSManaged public func addToBarmenu(_ value: Bar)

    @objc(removeBarmenuObject:)
    @NSManaged public func removeFromBarmenu(_ value: Bar)

    @objc(addBarmenu:)
    @NSManaged public func addToBarmenu(_ values: NSSet)

    @objc(removeBarmenu:)
    @NSManaged public func removeFromBarmenu(_ values: NSSet)

}

// MARK: Generated accessors for barspecialties
extension Drink {

    @objc(addBarspecialtiesObject:)
    @NSManaged public func addToBarspecialties(_ value: Bar)

    @objc(removeBarspecialtiesObject:)
    @NSManaged public func removeFromBarspecialties(_ value: Bar)

    @objc(addBarspecialties:)
    @NSManaged public func addToBarspecialties(_ values: NSSet)

    @objc(removeBarspecialties:)
    @NSManaged public func removeFromBarspecialties(_ values: NSSet)

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
