//
//  Glass+CoreDataProperties.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/15/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData


extension Glass {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Glass> {
        return NSFetchRequest<Glass>(entityName: "Glass");
    }

    @NSManaged public var displayName: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var drink: NSSet?

}

// MARK: Generated accessors for drink
extension Glass {

    @objc(addDrinkObject:)
    @NSManaged public func addToDrink(_ value: Drink)

    @objc(removeDrinkObject:)
    @NSManaged public func removeFromDrink(_ value: Drink)

    @objc(addDrink:)
    @NSManaged public func addToDrink(_ values: NSSet)

    @objc(removeDrink:)
    @NSManaged public func removeFromDrink(_ values: NSSet)

}
