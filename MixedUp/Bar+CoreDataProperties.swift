//
//  Bar+CoreDataProperties.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData


extension Bar {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bar> {
        return NSFetchRequest<Bar>(entityName: "Bar");
    }

    @NSManaged public var id: String?
    @NSManaged public var inventory: NSSet?
    @NSManaged public var drinks: NSSet?
    @NSManaged public var menu: NSSet?
    @NSManaged public var specialties: NSSet?
    @NSManaged public var managers: NSSet?
    @NSManaged public var location: Location?

}

// MARK: Generated accessors for inventory
extension Bar {

    @objc(addInventoryObject:)
    @NSManaged public func addToInventory(_ value: Ingredient)

    @objc(removeInventoryObject:)
    @NSManaged public func removeFromInventory(_ value: Ingredient)

    @objc(addInventory:)
    @NSManaged public func addToInventory(_ values: NSSet)

    @objc(removeInventory:)
    @NSManaged public func removeFromInventory(_ values: NSSet)

}

// MARK: Generated accessors for drinks
extension Bar {

    @objc(addDrinksObject:)
    @NSManaged public func addToDrinks(_ value: Drink)

    @objc(removeDrinksObject:)
    @NSManaged public func removeFromDrinks(_ value: Drink)

    @objc(addDrinks:)
    @NSManaged public func addToDrinks(_ values: NSSet)

    @objc(removeDrinks:)
    @NSManaged public func removeFromDrinks(_ values: NSSet)

}

// MARK: Generated accessors for menu
extension Bar {

    @objc(addMenuObject:)
    @NSManaged public func addToMenu(_ value: Drink)

    @objc(removeMenuObject:)
    @NSManaged public func removeFromMenu(_ value: Drink)

    @objc(addMenu:)
    @NSManaged public func addToMenu(_ values: NSSet)

    @objc(removeMenu:)
    @NSManaged public func removeFromMenu(_ values: NSSet)

}

// MARK: Generated accessors for specialties
extension Bar {

    @objc(addSpecialtiesObject:)
    @NSManaged public func addToSpecialties(_ value: Drink)

    @objc(removeSpecialtiesObject:)
    @NSManaged public func removeFromSpecialties(_ value: Drink)

    @objc(addSpecialties:)
    @NSManaged public func addToSpecialties(_ values: NSSet)

    @objc(removeSpecialties:)
    @NSManaged public func removeFromSpecialties(_ values: NSSet)

}

// MARK: Generated accessors for managers
extension Bar {

    @objc(addManagersObject:)
    @NSManaged public func addToManagers(_ value: User)

    @objc(removeManagersObject:)
    @NSManaged public func removeFromManagers(_ value: User)

    @objc(addManagers:)
    @NSManaged public func addToManagers(_ values: NSSet)

    @objc(removeManagers:)
    @NSManaged public func removeFromManagers(_ values: NSSet)

}
