//
//  Ingredient+CoreDataProperties.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/15/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData


extension Ingredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient");
    }

    @NSManaged public var displayName: String?
    @NSManaged public var id: String?
    @NSManaged public var isAlcoholic: Bool
    @NSManaged public var name: String?
    @NSManaged public var bar: NSSet?
    @NSManaged public var drink: NSSet?
    @NSManaged public var type: IngredientType?
    @NSManaged public var user: NSSet?

}

// MARK: Generated accessors for bar
extension Ingredient {

    @objc(addBarObject:)
    @NSManaged public func addToBar(_ value: Bar)

    @objc(removeBarObject:)
    @NSManaged public func removeFromBar(_ value: Bar)

    @objc(addBar:)
    @NSManaged public func addToBar(_ values: NSSet)

    @objc(removeBar:)
    @NSManaged public func removeFromBar(_ values: NSSet)

}

// MARK: Generated accessors for drink
extension Ingredient {

    @objc(addDrinkObject:)
    @NSManaged public func addToDrink(_ value: Drink)

    @objc(removeDrinkObject:)
    @NSManaged public func removeFromDrink(_ value: Drink)

    @objc(addDrink:)
    @NSManaged public func addToDrink(_ values: NSSet)

    @objc(removeDrink:)
    @NSManaged public func removeFromDrink(_ values: NSSet)

}

// MARK: Generated accessors for user
extension Ingredient {

    @objc(addUserObject:)
    @NSManaged public func addToUser(_ value: User)

    @objc(removeUserObject:)
    @NSManaged public func removeFromUser(_ value: User)

    @objc(addUser:)
    @NSManaged public func addToUser(_ values: NSSet)

    @objc(removeUser:)
    @NSManaged public func removeFromUser(_ values: NSSet)

}
