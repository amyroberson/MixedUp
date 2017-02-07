//
//  User+CoreDataProperties.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var email: String?
    @NSManaged public var id: String?
    @NSManaged public var inventory: NSSet?
    @NSManaged public var favoriteDrinks: NSSet?
    @NSManaged public var barsManaged: NSSet?

}

// MARK: Generated accessors for inventory
extension User {

    @objc(addInventoryObject:)
    @NSManaged public func addToInventory(_ value: Ingredient)

    @objc(removeInventoryObject:)
    @NSManaged public func removeFromInventory(_ value: Ingredient)

    @objc(addInventory:)
    @NSManaged public func addToInventory(_ values: NSSet)

    @objc(removeInventory:)
    @NSManaged public func removeFromInventory(_ values: NSSet)

}

// MARK: Generated accessors for favoriteDrinks
extension User {

    @objc(addFavoriteDrinksObject:)
    @NSManaged public func addToFavoriteDrinks(_ value: Drink)

    @objc(removeFavoriteDrinksObject:)
    @NSManaged public func removeFromFavoriteDrinks(_ value: Drink)

    @objc(addFavoriteDrinks:)
    @NSManaged public func addToFavoriteDrinks(_ values: NSSet)

    @objc(removeFavoriteDrinks:)
    @NSManaged public func removeFromFavoriteDrinks(_ values: NSSet)

}

// MARK: Generated accessors for barsManaged
extension User {

    @objc(addBarsManagedObject:)
    @NSManaged public func addToBarsManaged(_ value: Bar)

    @objc(removeBarsManagedObject:)
    @NSManaged public func removeFromBarsManaged(_ value: Bar)

    @objc(addBarsManaged:)
    @NSManaged public func addToBarsManaged(_ values: NSSet)

    @objc(removeBarsManaged:)
    @NSManaged public func removeFromBarsManaged(_ values: NSSet)

}
